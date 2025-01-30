import 'dart:io';
import 'package:flutter/material.dart';
import 'package:memo_program/pages/add_memo.dart';
import 'package:memo_program/widgets/memo_widget.dart';
import 'package:memo_program/styles/memo_style.dart';
import 'package:memo_program/services/memo_services.dart';
import '../models/memo.dart';

class MemoCheckPage extends StatefulWidget {
  final Memo memo;

  MemoCheckPage({super.key, required this.memo});

  @override
  _MemoCheckPageState createState() => _MemoCheckPageState();
}

class _MemoCheckPageState extends State<MemoCheckPage> {
  late Memo memo;

  @override
  void initState() {
    super.initState();
    memo = widget.memo; // 获取传递的 memo 数据
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MemoStyle.memoBackGroundColor,
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 392,
          height: 700,
          margin: const EdgeInsets.only(top: 50),
          decoration: MemoStyle.cardDecoration,
          child: Stack(
            children: [
              Row(
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
                  Container(
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
                ],
              ),
              Positioned( //标题
                top: 90, left: 51, right: 51,
                child: SizedBox(width: 250,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                child:Text(
                  memo.title,
                  style: MemoStyle.titleTextStyle,
                ),
              ),),),
              Container(//标题下面的线
                margin: const EdgeInsets.only(top: 128, left: 51, right: 51, bottom: 20,),
                child: const Divider(
                  height: 1,
                  color: Color.fromRGBO(200, 200, 200, 1),
                  thickness: 1,
                ),
              ),
              Positioned(
                top: 80,
                left: 305,
                child: DeleteMemoWidget(memo: memo),
              ),
              Positioned(
                top: 156, left: 51, right: 51,
                child: SizedBox(
                  height: 360, // 限制滚动区域
                  child: SingleChildScrollView(
                    child: Text(
                      memo.content,
                      style: MemoStyle.bodyTextStyle,
                    ),
                  ),
                ),
              ),
              Container(
                height: 100,
                margin: const EdgeInsets.only(top: 580, left: 31),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: memo.images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [MemoStyle.cardShadow],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(memo.images[index]), // 显示所有图片
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 560),
                child: const Divider(
                  height: 1,
                  color: Color.fromRGBO(200, 200, 200, 1),
                  thickness: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
