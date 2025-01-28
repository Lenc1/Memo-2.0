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
          height: 700,
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
                      InkWell(
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
                        margin: const EdgeInsets.only(top: 37, left: 150),
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
                            backgroundColor:
                                const Color.fromRGBO(64, 185, 222, 1),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 17, vertical: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            '保存',
                            style: TextStyle(
                              fontFamily: 'SourceHanSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        top: 12, left: 51, right: 51),
                    child: const TextField(
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'SourceHanSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(46, 46, 46, 1),
                      ),
                      decoration: InputDecoration(
                        hintText: '标题',
                        hintStyle: TextStyle(
                          color: Color.fromRGBO(130, 130, 130, 1),
                        ),
                        border: InputBorder.none, //取消下划线
                      ),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 51,right: 51,bottom: 20),
                      child: const Divider(
                        height: 1,
                        color: Color.fromRGBO(200, 200, 200, 1),
                        thickness: 1,
                      )),
                  Container(
                    margin: const EdgeInsets.only(left: 51, right: 51),
                    child: Column(
                      children: [
                        _isEditing
                            ? TextField(
                                maxLines: 10,
                                style: const TextStyle(
                                  fontFamily: 'SourceHanSans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(46, 46, 46, 1),
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
                                  hintStyle: TextStyle(
                                    color: Color.fromRGBO(130, 130, 130, 1),
                                  ),
                                  border: InputBorder.none, //取消下划线
                                ),
                                // TODO: markdown显示
                              )
                            : Expanded(
                                child: SingleChildScrollView(
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
                  Stack(
                    children: [
                      const SizedBox(height: 150),
                      if (_images.isNotEmpty) ...[
                        const SizedBox(height: 40),
                        const Text(
                          '已选择的图片：',
                          style: TextStyle(fontFamily: 'SourceHanSans'),
                        ),
                        Container(
                          height: 82,
                          margin: const EdgeInsets.symmetric(horizontal: 51),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 82,
                                height: 82,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const[
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.25),
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                        spreadRadius: 0,
                                      )
                                    ]
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _images[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),

                  const Divider(
                    height: 1,
                    color: Color.fromRGBO(200, 200, 200, 1),
                    thickness: 1,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          print("picking Image...");
                          _pickImages();
                        },
                        child: Container(
                          alignment: Alignment.topLeft,
                          width: 150,
                          margin: const EdgeInsets.only(top: 10, left: 51),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 29,
                                height: 29,
                                decoration: const BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'lib/assets/photos.png'))),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              _images.isEmpty
                                  ? const Text(
                                      '上传照片',
                                      style: TextStyle(
                                        fontFamily: 'SourceHanSans',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromRGBO(130, 130, 130, 1),
                                      ),
                                    )
                                  : const Text(
                                      '重新选择',
                                      style: TextStyle(
                                        fontFamily: 'SourceHanSans',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromRGBO(130, 130, 130, 1),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
