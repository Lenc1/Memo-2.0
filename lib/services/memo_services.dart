import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../models/memo.dart';
import '../widgets/memo_widget.dart';

class CURDManager {
  //TODO 图片存储逻辑修改：只存储图片文件名，不保存绝对路径
  static Future<void> savePicture(
    String originPath,
  ) async {
    final targetPath = await FilePicker.platform.getDirectoryPath();
    final now = DateTime.now();
    final picSec = now.millisecondsSinceEpoch.toString();
    if (targetPath != null) {
      String optPath = path.join(targetPath,
          'memoPic_$picSec.${originPath.split('.').last}');
      try {
        print(originPath);
        print(targetPath);
        print(optPath);
        await File(originPath).copy(optPath);
        print("保存成功");
      } catch (e) {
        print("图片复制失败：$e");
      }
    }
  }

  static Future<String?> movePicture(String originPath) async {
    final directory = await PathManager.getSavePath();
    final optPath = Directory(path.join(directory, 'pictures'));

    if (!await optPath.exists()) {
      await optPath.create(recursive: true);
    }

    final fileName =
        'memoPic_${DateTime.now().millisecondsSinceEpoch}.${originPath.split('.').last}';
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
    var status = await Permission.storage.status;
    if(status.isDenied) {
      status = await Permission.storage.request();
    }
    if(status.isGranted){

    } else if(status.isPermanentlyDenied){
      openAppSettings();
    }
    if (controller.text.isNotEmpty) {
      final now = DateTime.now();
      List<String> imagePaths = [];
      for (var image in images) {
        if (image.path.contains('memoPic_')) {
          imagePaths.add(image.path);
        } else {
          final newImagePath = await movePicture(image.path);
          if (newImagePath != null) {
            imagePaths.add(newImagePath);
          }
        }
      }
      final newMemo = Memo(
        title: titleController.text,
        content: controller.text,
        images: imagePaths,
        created_at: memo?.created_at ?? now.toIso8601String(),
        milliseconds:
            memo?.milliseconds ?? now.millisecondsSinceEpoch.toString(),
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
    final file = File(path.join(
        directory, 'memo_${memo.milliseconds}.json')); // 使用 path.join 来拼接路径
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

  static Future<String> pickPath() async {
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
      return 'memo已移动至$directoryPath';
    }
    return '路径选择错误';
  }
  static Future<String> pressMemo(bool? key) async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      final memoPath = await getSavePath();
      final archive = Archive();
      final dir = Directory(memoPath);
      final files = dir.listSync(recursive: true).whereType<File>();

      for (final file in files) {
        final fileBytes = await file.readAsBytes();
        final relativePath = path.relative(file.path, from: memoPath);
        final archiveFile = ArchiveFile(relativePath, file.lengthSync(), fileBytes);
        archive.addFile(archiveFile);
      }

      final now = DateTime.now();
      final zipFilePath = path.join(directoryPath, 'memo_archive_${now.millisecondsSinceEpoch}.zip');

      final zipData = ZipEncoder().encode(archive);
      await File(zipFilePath).writeAsBytes(zipData);

      debugPrint('ZIP file created at: $zipFilePath');
      if(key ?? false) clearMemoFolder();
      return '压缩并保存成功';

    }
    return '没有选择路径';
  }

  static Future<String> extractMemo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['zip']);
    if (result == null || result.files.isEmpty) {
      return '没有选择文件';
    }
    final zipFilePath = result.files.single.path;
    if (zipFilePath == null) {
      return '无效的文件路径';
    }
    // 获取 memos 文件夹路径
    final memoPath = await getSavePath();
    // 读取 ZIP 文件内容
    final zipFile = File(zipFilePath);
    if (!await zipFile.exists()) {
      return 'ZIP 文件不存在';
    }
    // 解压 ZIP 文件
    final zipData = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(zipData);

    // 遍历解压文件，保存到 memos 文件夹
    for (final file in archive) {
      if (file.isFile) {
        final filePath = path.join(memoPath, file.name);

        // 创建包含文件的文件夹（如果不存在）
        final fileDirectory = path.dirname(filePath);
        final directory = Directory(fileDirectory);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        final outFile = File(filePath);
        await outFile.writeAsBytes(file.content as List<int>);
        print('解压文件: ${file.name}');
      }
    }
    return'导入成功！';
  }
  static Future<String> getSavePath() async {
    // 获取基础路径
    final basePath =
        customPath ?? (await getApplicationDocumentsDirectory()).path;

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
  static Future<void> clearMemoFolder() async {
    final memoPath = await getSavePath();
    await Directory(memoPath).list(recursive: true).forEach((file) async {
      if (file is File) {
        await file.delete(); // 删除文件
        print('已删除文件: ${file.path}');
      }
    });
    print('清空完成');
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
          final newFile =
              File(path.join(newSavePath, path.basename(file.path)));

          try {
            await file.copy(newFile.path);
            await file.delete();
            debugPrint('Moved: ${file.path} → ${newFile.path}');
          } catch (e) {
            debugPrint('Failed to move ${file.path}: $e');
          }
        }
      }
    }
  }

  static bool _isMemoFile(File file) {
    return path.basename(file.path).startsWith('memo_') &&
        path.extension(file.path) == '.json';
  }
}
