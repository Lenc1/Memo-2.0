import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/memo.dart';

// 删除 memo 的服务函数
Future<void> deleteMemo(Memo memo, VoidCallback onDeleteSuccess) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/memo_${memo.milliseconds}.json');

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

Future<String?> pickPath() async{
  String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      // 获取选择的文件夹路径
      print("选择的文件夹路径: $directoryPath");
    } else {
      print("没有选择文件夹");
    }
}

Future<void> openFloderPath() async{

}
