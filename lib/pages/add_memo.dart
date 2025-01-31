// add_memo.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memo_program/widgets/memo_widget.dart';
import 'dart:io';
import 'package:memo_program/styles/memo_style.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import '../models/memo.dart';
import '../widgets/image_view.dart';

class NewDiaryPage extends StatefulWidget {
  final Memo? memo;

  const NewDiaryPage({super.key, required this.memo});

  @override
  _NewDiaryPageState createState() => _NewDiaryPageState();
}

class _NewDiaryPageState extends State<NewDiaryPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  bool _isCheck = false;
  String viewPic = '';

  @override
  void initState() {
    super.initState();
    if (widget.memo != null) {
      _titleController.text = widget.memo!.title;
      _controller.text = widget.memo!.content;
      _images = widget.memo!.images.map((path) => File(path)).toList();
    }
  }

  void _viewImage(String path) {
    setState(() {
      _isCheck = true;
      viewPic = path;
    });
  }

  void _closeImageViewer() {
    setState(() {
      _isCheck = false;
    });
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.length <= 3) {
      setState(() {
        _images = pickedFiles.map((e) {
          return File(e.path);
        }).toList();
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const MemoReminderPop(
              title: '提示', content: '最多只能选择3张图片', action: '确定');
        },
      );
    }
  }

  void _saveMemo() async {
    if (_controller.text.isNotEmpty && _images.isNotEmpty) {
      final now = DateTime.now();
      final newMemo = Memo(
        title: _titleController.text,
        content: _controller.text,
        images: _images.map((file) => file.path).toList(),
        // 保存图片路径
        created_at: widget.memo?.created_at ?? now.toIso8601String(),
        // 如果是编辑模式，保留原创建时间
        milliseconds: widget.memo?.milliseconds ??
            now.millisecondsSinceEpoch.toString(), // 如果是编辑模式，保留原时间戳
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/memo_${newMemo.milliseconds}.json');
      final memoJson = jsonEncode(newMemo.toJson());
      await file.writeAsString(memoJson);

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

  String _inputText = '';
  bool _isEditing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false, //关键一行，优化溢出
        backgroundColor: MemoStyle.memoBackGroundColor,
        body: Align(
          alignment: Alignment.topCenter,
          child: Stack(children: [
            Container(
              margin: const EdgeInsets.only(top: 50),
              decoration: MemoStyle.cardDecoration,
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
                                margin:
                                    const EdgeInsets.only(top: 37, left: 54),
                                child: const MemoBackButton(),
                              )),
                          Container(
                            margin: const EdgeInsets.only(top: 37, left: 150),
                            child: IconButton(
                              icon: Icon(
                                  _isEditing ? Icons.menu_book : Icons.edit),
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
                                padding:
                                    const EdgeInsets.only(left: 17, right: 17),
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
                        margin:
                            const EdgeInsets.only(top: 12, left: 51, right: 51),
                        child: TextField(
                          maxLines: 1,
                          maxLength: 12,
                          style: MemoStyle.titleTextStyle,
                          controller: _titleController,
                          onChanged: (text) {
                            setState(() {
                              print('ovo');
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: '标题',
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(130, 130, 130, 1),
                            ),
                            border: InputBorder.none, //取消下划线
                            counterText: '', //隐藏原版字符数显示
                          ),
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.only(
                            left: 51,
                            right: 51,
                            bottom: 20,
                          ),
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
                                    maxLines: 11,
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
                                : const Expanded(
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
                      const SizedBox(height: 50),
                      Stack(
                        children: [
                          //ClipRRect(child: const SizedBox(height: 150),),
                          if (_images.isNotEmpty) ...[
                            Container(
                              height: 95,
                              margin: const EdgeInsets.only(left: 31),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _images.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () =>
                                        _viewImage(_images[index].path),
                                    child: Container(
                                      width: 95,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          boxShadow: [MemoStyle.cardShadow]),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _images[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
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
            Container(
              margin: const EdgeInsets.only(top: 160, left: 290),
              child: Text(
                '${_titleController.text.length}/12',
                style: MemoStyle.bodyHintTextStyle,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 530, left: 290),
              child: Text(
                '字数:${_controller.text.length}',
                style: MemoStyle.bodyHintTextStyle.copyWith(
                  fontSize: 16,
                ),
              ),
            ),
            if (_isCheck)
              InkWell(
                  onTap: _closeImageViewer,
                  child: ImageViewerBuilder(
                    path: viewPic,
                  ))
          ]),
        ));
  }
}
