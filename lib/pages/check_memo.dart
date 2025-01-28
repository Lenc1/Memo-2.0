import 'package:flutter/material.dart';
import 'package:memo_program/models/memo_widget.dart';
import 'package:memo_program/styles/memo_style.dart';
import '../pages/new_diary.dart';

class MemoCheckPage extends StatelessWidget {
  final DiaryEntry diary;

  const MemoCheckPage({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MemoStyle.memoBackGroundColor,
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 392,
          height: 700,
          margin: const EdgeInsets.only(top: 22, left: 10, right: 10),
          decoration: MemoStyle.cardDecoration,
          child: Stack(
            children: [
                 Container(
                  margin: const EdgeInsets.only(top: 37, left: 54),
                  child: InkWell(onTap: () {
                    print("back");
                    Navigator.pop(context);
                  },
                    child: const MemoBackButton(),),
                ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  diary.content,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              // const SizedBox(height: 20),
              // if (diary.images.isNotEmpty) ...[
              //   const Text('日记图片：'),
              //   SizedBox(
              //     height: 100,
              //     child: ListView.builder(
              //       scrollDirection: Axis.horizontal,
              //       itemCount: diary.images.length,
              //       itemBuilder: (context, index) {
              //         return Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 5.0),
              //           child: Image.file(
              //             diary.images[index],
              //             width: 80,
              //             height: 80,
              //             fit: BoxFit.cover,
              //           ),
              //         );
              //       },
              //     ),
              //   ),
              //],
            ],
          ),
        ),
      ),
    );
  }
}
