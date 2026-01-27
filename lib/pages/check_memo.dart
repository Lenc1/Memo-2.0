import 'dart:io';
import 'package:flutter/material.dart';
import 'package:memo_program/pages/add_memo.dart';
import 'package:memo_program/services/memo_services.dart';
import 'package:memo_program/widgets/image_view.dart';
import 'package:path/path.dart' as path show join;
import 'package:memo_program/widgets/memo_widget.dart';
import 'package:memo_program/styles/memo_style.dart';
import '../models/memo.dart';

class MemoCheckPage extends StatefulWidget {
  final Memo memo;
  final String imgPath;
  const MemoCheckPage({super.key, required this.memo, required this.imgPath});

  @override
  _MemoCheckPageState createState() => _MemoCheckPageState();
}

class _MemoCheckPageState extends State<MemoCheckPage> {
  late Memo memo;
  bool _isCheck = false;
  String viewPic = '';
  String imgPath = '';
  @override
  void initState() {
    super.initState();
    memo = widget.memo;
    viewPic = widget.memo.images.isNotEmpty ? widget.memo.images[0] : '';
    imgPath = widget.imgPath;
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

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: MemoStyle.memoBackGroundColor,
      body: Align(
          alignment: Alignment.topCenter,
          child: Stack(
            children: [
              Container(
                height: screenHeight - 90,
                margin: const EdgeInsets.only(top: 50),
                decoration: MemoStyle.cardDecoration,
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 37, left: 54),
                      child: InkWell(
                        onTap: () {
                          print("back");
                          Navigator.pop(context);
                        },
                        child: const MemoBackButton(),
                      ),
                    ),
                    Positioned(
                      right: 50,
                      child: Container(
                        margin: const EdgeInsets.only(top: 37, left: 230),
                        child: IconButton(
                          icon: const Icon(Icons.mode_edit_outline_outlined),
                          color: const Color.fromRGBO(40, 40, 40, 1),
                          onPressed: () async {
                            final newMemo = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewDiaryPage(memo: memo),
                              ),
                            );
                            if (newMemo != null) {
                              setState(() {
                                memo = newMemo; // 更新 memo 并刷新 UI
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    Positioned(
                        top: 130,
                        right: 50,
                        child: SelectableText(
                          '${memo.created_at.substring(0, 10)}   ${memo.created_at.substring(11,19)}',
                          style: MemoStyle.bodyHintTextStyle.copyWith(
                            fontSize: 16,
                          ),
                        )),
                    Positioned(
                      top: 90,
                      left: 51,
                      right: 51,
                      child: SizedBox(
                        width: 250,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SelectableText(
                            memo.title,
                            style: MemoStyle.titleTextStyle,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 128,
                        left: 51,
                        right: 51,
                        bottom: 20,
                      ),
                      child: const Divider(
                        height: 1,
                        color: Color.fromRGBO(200, 200, 200, 1),
                        thickness: 1,
                      ),
                    ),
                    Positioned(
                      top: 80,
                      right: 50,
                      child: DeleteMemoWidget(memo: memo),
                    ),
                    Positioned(
                      top: 156,
                      left: 51,
                      right: 51,
                      child: SizedBox(
                        height: screenHeight * 0.3, // 限制滚动区域
                        child: SingleChildScrollView(
                          child: SelectableText(
                            memo.content,
                            style: MemoStyle.bodyTextStyle,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 100,
                      margin:
                          EdgeInsets.only(top: screenHeight * 0.62, left: 31),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: memo.images.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onTap: () => _viewImage(path.join(
                                    imgPath, 'pictures', memo.images[index])),
                                child: Container(
                                  width: 100,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [MemoStyle.cardShadow],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(path.join(imgPath, 'pictures',
                                          memo.images[index])), // 显示所有图片
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ));
                          },
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: screenHeight * 0.6),
                      child: const Divider(
                        height: 1,
                        color: Color.fromRGBO(200, 200, 200, 1),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isCheck)
                InkWell(
                    onLongPress: () async {
                      final confirm = await showSavePicDialog(context);
                      if (confirm ?? false) {
                        try {
                          final result = await CURDManager.savePicture(viewPic);
                          if(context.mounted) {
                            showDialog(context: context,
                                builder: (context) =>MemoReminderPop(
                                    title: '保存成功',
                                    content: result,
                                    action: '确定')
                            );
                          }
                        } catch (e) {
                          debugPrint('保存图片遇到错误: $e');
                        }
                      }
                    },
                    onTap: _closeImageViewer,
                    child: ImageViewerBuilder(
                      path: viewPic,
                    ))
            ],
          )),
    );
  }
}
