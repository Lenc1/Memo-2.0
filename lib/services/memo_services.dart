import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import '../models/memo.dart';
import '../widgets/memo_widget.dart';

Future<void> deleteMemo(Memo memo) async {
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

Future<void> handleDeleteMemo({
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
      // 可以在此显示错误信息提示给用户
    }
  }
}

class PathManager {
  static String? customPath;

  static Future<String?> pickPath() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      final oldSavePath = await getSavePath();
      await moveFile(oldSavePath, directoryPath);
      customPath = directoryPath;
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
      await directory.create(recursive: true);  // recursive: true 确保创建所有必要父目录
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

      // 删除旧目录（可选）
      try {
        await oldDirectory.delete(recursive: false);
      } catch (e) {
        debugPrint('Could not delete old directory: $e');
      }
    }
  }
  static bool _isMemoFile(File file) {
    return path.basename(file.path).startsWith('memo_') &&
        path.extension(file.path) == '.json';
  }
}
