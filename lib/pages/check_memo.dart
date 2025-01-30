import 'package:flutter/material.dart';
import 'package:memo_program/models/memo_widget.dart';
import 'package:memo_program/styles/memo_style.dart';

import '../models/memo.dart';


class MemoCheckPage extends StatelessWidget {
  final Memo memo;

  const MemoCheckPage({super.key, required this.memo});

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
                        onPressed: () {},
                      )),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 90, left: 51),
                child: Text(
                  memo.title,
                  style: MemoStyle.titleTextStyle,
                ),
              ),
              Container(
                  margin: const EdgeInsets.only(
                      top: 128, left: 51, right: 51, bottom: 20),
                  child: const Divider(
                    height: 1,
                    color: Color.fromRGBO(200, 200, 200, 1),
                    thickness: 1,
                  )),
              Container(
                margin: const EdgeInsets.only(top: 156, left: 51),
                child: Text(
                  memo.content,
                  maxLines: 15,
                  style: MemoStyle.bodyTextStyle,
                ),
              ),
              Container(
                height: 100,
                margin: const EdgeInsets.only(top: 580, left: 31),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal, // 横向滚动显示
                    itemCount: memo.images.length,  // 动态获取图片数量
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
                            memo.images[index],  // 显示所有图片
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
