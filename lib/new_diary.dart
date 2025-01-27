// new_diary.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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

  String _inputText = '';
  bool _isEditing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 251, 255, 1),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 392,
          height: 600,
          margin: const EdgeInsets.only(top: 22, left: 10, right: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Column(
                children: <Widget>[
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          print("back");
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 22,
                          height: 20,
                          margin: const EdgeInsets.only(top: 37, left: 54),
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('lib/assets/back.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top:37,left: 150),
                        child: IconButton(
                          icon: Icon(_isEditing ? Icons.menu_book : Icons.edit),
                          onPressed: () {
                            setState(() {
                              _isEditing = !_isEditing;
                            });
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20, top: 36),
                        child: ElevatedButton(
                          onPressed: _saveDiary,
                          style: ElevatedButton.styleFrom(
                            primary: const Color.fromRGBO(64, 185, 222, 1),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 17, vertical: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            '保存',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.only(left: 51, right: 51),
                    child: Column(
                      children: [
                        _isEditing ?
                        TextField(
                          maxLines: 10,
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                          controller: _controller,
                          onChanged: (text) {
                            setState(() {
                              print("_inputText");
                              _inputText = text;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: '在此输入文字...',
                          ),
                          // TODO: markdown显示
                        ): Expanded(child: SingleChildScrollView(
                          child: Markdown(
                          data: _inputText,
                            styleSheet: MarkdownStyleSheet(
                              h1: TextStyle(fontSize: 14),
                            ),
                          ),
                        ))
                      ],
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
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
                ],
              ),
            ],
          ),
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
