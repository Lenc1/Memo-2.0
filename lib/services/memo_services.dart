import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../models/memo.dart';
import '../widgets/memo_widget.dart';

class CURDManager{
  static Future<void> savePicture(
      String originPath,
      )async {
    final targetPath = await FilePicker.platform.getDirectoryPath();
    final now = DateTime.now();
    //final picFile = File(path);
    if(targetPath != null) {
      String optPath = path.join(targetPath,'memoPic_${now.millisecondsSinceEpoch.toString()}.${originPath.split('.').last}');
      try {
        print(originPath);
        print(targetPath);
        print(optPath);
        await File(originPath).copy(optPath);
        print("保存成功");
      } catch(e){
        print("图片复制失败：$e");
      }
    }
  }
  static Future<String?> movePicture(String originPath) async {
    final directory = await PathManager.getSavePath();
    final optPath = Directory(path.join(directory,'pictures'));

    // 如果文件夹不存在，则创建
    if (!await optPath.exists()) {
      await optPath.create(recursive: true);
    }

    // 获取新的图片文件名
    final fileName = 'memoPic_${DateTime.now().millisecondsSinceEpoch}.${originPath.split('.').last}';
    final newPath = path.join(optPath.path, fileName);

    try {
      print('原始路径: $originPath');
      print('目标路径: $newPath');
      await File(originPath).copy(newPath);
      print("图片保存成功");

      return newPath;
    } catch (e) {
      print("图片复制失败: $e");
    }
    return null;
  }
  static Future<void> saveMemo(
      BuildContext context,
      TextEditingController controller,
      TextEditingController titleController,
      List<File> images,
      Memo? memo, // 传递原始memo（如果是编辑模式）
      ) async {
    if (controller.text.isNotEmpty) {
      final now = DateTime.now();
      List<String> imagePaths = [];
      for(var image in images) {
        if (image.path.contains('memoPic_'))
        {
          imagePaths.add(image.path);
        } else {
          final newImagePath = await movePicture(image.path);
          if(newImagePath != null){
            imagePaths.add(newImagePath);
          }
        }
      }
      final newMemo = Memo(
        title: titleController.text,
        content: controller.text,
        images: imagePaths,
        created_at: memo?.created_at ?? now.toIso8601String(),
        milliseconds: memo?.milliseconds ?? now.millisecondsSinceEpoch.toString(),
      );

      // 获取保存路径
      final directory = await PathManager.getSavePath();
      final file = File('$directory/memo_${newMemo.milliseconds}.json');
      final memoJson = jsonEncode(newMemo.toJson());
      await file.writeAsString(memoJson);

      // 返回新的memo
      Navigator.pop(context, newMemo);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const MemoReminderPop(
              title: '提示', content: '请填写内容并选择至少1张图片', action: '确定');
        },
      );
    }
  }
  static Future<void> deleteMemo(Memo memo) async {
    final directory = await PathManager.getSavePath();
    final file = File(path.join(directory, 'memo_${memo.milliseconds}.json'));  // 使用 path.join 来拼接路径

    try {
      if (await file.exists()) {
        await file.delete();
        debugPrint('文件删除成功: ${file.path}');
      } else {
        debugPrint('文件不存在: ${file.path}');
      }
    } catch (e) {
      debugPrint('删除失败: $e');
      rethrow;
    }
  }

  static Future<void> handleDeleteMemo({
    required BuildContext context,
    required Memo memo,
    required VoidCallback onSuccess,
  }) async {
    final confirm = await showDeleteDialog(context);
    if (confirm ?? false) {
      try {
        await deleteMemo(memo);
        onSuccess();
        debugPrint("删除成功");
      } catch (e) {
        debugPrint('删除操作遇到错误: $e');
      }
    }
  }
}


class PathManager {
  static String? customPath;

  static Future<String?> pickPath() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      final oldSavePath = await getSavePath();
      final comPath = path.join(directoryPath, 'memos');
      if (comPath != oldSavePath) {
        await moveFile(oldSavePath, directoryPath);
        customPath = directoryPath;
      } else {
        debugPrint('选择的路径与旧路径相同，无需移动文件');
      }
      return directoryPath;
    }
    return null;
  }

  static Future<String> getSavePath() async {
    // 获取基础路径
    final basePath = customPath ?? (await getApplicationDocumentsDirectory()).path;

    // 拼接完整保存路径
    final fullPath = path.join(basePath, 'memos');

    // 创建目录（如果不存在）
    final directory = Directory(fullPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      debugPrint('Created directory: $fullPath');
    }

    return fullPath;
  }

  static Future<void> moveFile(String oldSavePath, String newRootPath) async {
    final oldDirectory = Directory(oldSavePath);

    if (await oldDirectory.exists()) {
      // 创建新目录路径（新根路径 + memos）
      final newSavePath = path.join(newRootPath, 'memos');
      final newDirectory = Directory(newSavePath);

      if (!await newDirectory.exists()) {
        await newDirectory.create(recursive: true);
      }

      // 迁移所有符合条件的文件
      final files = oldDirectory.listSync().whereType<File>();
      for (final file in files) {
        if (_isMemoFile(file)) {
          final newFile = File(path.join(newSavePath, path.basename(file.path)));

          try {
            await file.copy(newFile.path);
            await file.delete();
            debugPrint('Moved: ${file.path} → ${newFile.path}');
          } catch (e) {
            debugPrint('Failed to move ${file.path}: $e');
          }
        }
      }
      // try {
      //   await oldDirectory.delete(recursive: false);
      // } catch (e) {
      //   debugPrint('Could not delete old directory: $e');
      // }
    }
  }
  static bool _isMemoFile(File file) {
    return path.basename(file.path).startsWith('memo_') &&
        path.extension(file.path) == '.json';
  }
}
