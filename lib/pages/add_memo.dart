// add_memo.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memo_program/models/memo_widget.dart';
import 'dart:io';
import 'package:memo_program/styles/memo_style.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import '../models/memo.dart';

class NewDiaryPage extends StatefulWidget {
  const NewDiaryPage({super.key});

  @override
  _NewDiaryPageState createState() => _NewDiaryPageState();
}

class _NewDiaryPageState extends State<NewDiaryPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.length <= 3) {
      setState(() {
        _images = pickedFiles.map((e) {
          return File(e.path);
        }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能选择三张图片')),
      );
    }
  }


  void _saveMemo() async{
    if (_controller.text.isNotEmpty && _images.isNotEmpty) {
      final newMemo = Memo(
        title: _titleController.text,
        content: _controller.text,
        images: _images,
        created_at: DateTime.now().toIso8601String(),
      );
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/memo_${DateTime.now().millisecondsSinceEpoch}.json');
      final memoJson = jsonEncode(newMemo.toJson());
      await file.writeAsString(memoJson);
      print(directory.path);
      Navigator.pop(context, newMemo);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请填写日记内容并至少选择一张图片',style: MemoStyle.bodyTextStyle.copyWith(
          color: Colors.white,
        ),)),
      );
    }
  }

  String _inputText = '';
  bool _isEditing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MemoStyle.memoBackGroundColor,
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 392,
          height: double.infinity,
          margin: const EdgeInsets.only(top: 50),
          decoration: MemoStyle.cardDecoration,
          child: Column(
            children: [
              Column(
                children: <Widget>[
                  Row(
                    children: [
                      InkWell(onTap: () {
                        print("back");
                        Navigator.pop(context);
                      },
                        child: Container(
                            margin: const EdgeInsets.only(top: 37, left: 54),
                              child: const MemoBackButton(),
                            )
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
                          onPressed: _saveMemo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(64, 185, 222, 1),
                            padding: const EdgeInsets.only(left: 17,right: 17),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            '保存',
                            style: MemoStyle.bodyTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 12, left: 51, right: 51),
                    child: TextField(
                      maxLines: 1,
                      style: MemoStyle.titleTextStyle,
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: '标题',
                        hintStyle: TextStyle(
                          color: Color.fromRGBO(130, 130, 130, 1),
                        ),
                        border: InputBorder.none, //取消下划线
                      ),
                    ),
                  ),
                  const Positioned(
                      left: 51, right: 51, bottom: 20,
                      child: Divider(
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
                                style: MemoStyle.bodyTextStyle,
                                controller: _controller,
                                onChanged: (text) {
                                  setState(() {
                                    print("_inputText");
                                    _inputText = text;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: '在此输入文字...',
                                  hintStyle: MemoStyle.bodyHintTextStyle,
                                  border: InputBorder.none, //取消下划线
                                ),
                                // TODO: markdown显示
                              )
                            : Expanded(
                                child: SingleChildScrollView(
                                // child: Markdown(
                                //   data: _inputText,
                                //   styleSheet: MarkdownStyleSheet(
                                //     h1: TextStyle(fontSize: 14),
                                //   ),
                                // ),
                              ))
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      ClipRRect(child: const SizedBox(height: 150),),
                      if (_images.isNotEmpty) ...[
                        Container(
                          height: 95,
                          margin: const EdgeInsets.only(top: 30, left: 31),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 95,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [MemoStyle.cardShadow]),
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
                              Text(
                                _images.isEmpty ? '上传照片' : '重新选择',
                                style: MemoStyle.bodyHintTextStyle,
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
