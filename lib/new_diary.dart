// new_diary.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewDiaryPage extends StatefulWidget {
  const NewDiaryPage({super.key});

  @override
  _NewDiaryPageState createState() => _NewDiaryPageState();
}

class _NewDiaryPageState extends State<NewDiaryPage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.length <= 3) {
      setState(() {
        _images = pickedFiles.map((e) => File(e.path)).toList();
      });
    } else {
      // 提示最多选择3张图片
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能选择三张图片')),
      );
    }
  }

  void _saveDiary() {
    if (_controller.text.isNotEmpty && _images.isNotEmpty) {
      final newDiary = DiaryEntry(
        content: _controller.text,
        images: _images,
      );
      Navigator.pop(context, newDiary);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写日记内容并选择图片')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建日记'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Text(
              '请输入您的日记内容：',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 10,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '在这里写下您的日记...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImages,
              child: const Text('选择图片（最多3张）'),
            ),
            const SizedBox(height: 20),
            if (_images.isNotEmpty) ...[
              const Text('已选择的图片：'),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Image.file(
                        _images[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveDiary,
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('保存日记'),
            ),
          ],
        ),
      ),
    );
  }
}

class DiaryEntry {
  String content;
  List<File> images;

  DiaryEntry({required this.content, required this.images});
}
