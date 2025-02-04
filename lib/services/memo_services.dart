import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/memo.dart';

// 删除 memo 的服务函数
Future<void> deleteMemo(Memo memo, VoidCallback onDeleteSuccess) async {
  try {
    final directory = await PathManager.getSavePath();
    final file = File('$directory/memo_${memo.milliseconds}.json');

    if (await file.exists()) {
      await file.delete();
      debugPrint('文件删除成功: ${file.path}');
      onDeleteSuccess();
    } else {
      debugPrint('文件不存在: ${file.path}');
    }
  } catch (e) {
    debugPrint('删除失败: $e');
    rethrow;
  }
}
class PathManager{
  static String? customPath;
  static Future<String?> pickPath() async{
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      await moveFile(directoryPath);
      customPath = directoryPath;
      return directoryPath;
    } else {
      return null;
    }
  }
  static Future<String> getSavePath() async{
    if(customPath!=null) {
      return customPath!;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }
  static Future<void> moveFile(String newPath) async{
    final oldPath = customPath;
    if (oldPath != null) {
      final oldDirectory = Directory(oldPath);
      if (await oldDirectory.exists()) {
        var files = oldDirectory.listSync(recursive: false);
        for (var file in files) {
          if (file is File && file.path.endsWith('memo_')) {
            try {
              final newFile = File('$newPath/${file.uri.pathSegments.last}');
              await file.rename(newFile.path);
              print('文件移动成功: ${file.path} -> ${newFile.path}');
            } catch (e) {
              print('移动文件失败: ${file.path}，错误: $e');
            }
          }
        }
      }
  }
  }
}
