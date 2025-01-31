import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../config/memo_config.dart';
import '../models/heat_map.dart';
import '../models/memo.dart';
import '../services/memo_services.dart';
import '../styles/memo_style.dart';

class NewMemoWidget extends StatelessWidget {
  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  const NewMemoWidget({super.key,required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 363,
      height: 156,
      margin: const EdgeInsets.only(right: 11, left: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(0, 0, 0, 1),
            Color.fromRGBO(102, 102, 102, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        onTap: () {
          print('open');
          onPressed();
        },
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Container(
              width: 173,
              height: 54,
              margin: const EdgeInsets.only(left: 20, top: 48),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(156, 204, 219, 1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Container(
                margin: const EdgeInsets.only(left: 54, top: 16),
                child: const Text(
                  '添加Memo',
                  style: TextStyle(
                    fontFamily: 'SourceHanSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              width: 196,
              height: 130,
              margin: const EdgeInsets.only(
                  top: 13, right: 12, left: 155, bottom: 13),
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ]),
              child: Container(
                margin: const EdgeInsets.only(top: 24, left: 22, bottom: 68),
                child: Text(
                  _getCurrentDate(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(top: 56, left: 32),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/addition_fill.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: 35,
              height: 35,
              margin: const EdgeInsets.only(top: 5, left: 290),
              decoration: const BoxDecoration(
                  image:
                      DecorationImage(image: AssetImage('lib/assets/tag.png'))),
            ),
            Container(
              width: 60,
              height: 70,
              margin: const EdgeInsets.only(top: 73, left: 261),
              decoration: const BoxDecoration(
                  image:
                      DecorationImage(image: AssetImage('lib/assets/pen.png'))),
            ),
          ],
        ),
      ),
    );
  }
}

class MemoListViewBuilder extends StatelessWidget {
  final List<Memo> memos;
  final void Function(Memo) onPressed;

  const MemoListViewBuilder({super.key,required this.memos, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: memos.length,
      itemBuilder: (context, index) {
        final memo = memos[memos.length - index - 1];
        return Container(
          padding: const EdgeInsets.only(bottom: 16),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (context) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("确认删除", style: MemoStyle.titleTextStyle),
                        content: Text("确定要删除这条memo吗？", style: MemoStyle.bodyTextStyle),
                        actions: [
                          TextButton(
                            child: Text("取消", style: MemoStyle.dialogButtonTextStyle),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                          TextButton(
                            child: Text("删除", style: MemoStyle.dialogButtonTextStyle.copyWith(color: Colors.red)),
                            onPressed: () async{
                              await deleteMemo(memo, () {
                                print("删除成功");
                                Navigator.pop(ctx);
                                MemoConfig.toggleRefresh();
                              });
                            },
                          ),
                        ],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    );
                  },
                  backgroundColor: const Color.fromRGBO(255, 73, 73, 1),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 392,
                height: 156,
                decoration: MemoStyle.cardDecoration,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onPressed(memo),
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 29, left: 30),
                        child: Text(
                          memo.title.length > 10
                              ? '${memo.title.substring(0, 10)}...'
                              : memo.title,
                          overflow: TextOverflow.ellipsis,
                          style: MemoStyle.titleTextStyle.copyWith(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            top: 58, left: 30, right: 154),
                        child: const Divider(
                          height: 1,
                          color: Colors.grey,
                          thickness: 1,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 31, top: 63),
                        child: Text(
                          memo.content.length > 10
                              ? '${memo.content.substring(0, 10)}...'
                              : memo.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MemoStyle.bodyTextStyle.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 105, left: 31),
                        child: Text(
                          memo.created_at.substring(0, 10),
                          style: MemoStyle.bodyHintTextStyle.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Container(
                        width: 115,
                        height: 115,
                        margin: const EdgeInsets.only(top: 16, left: 250),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [MemoStyle.cardShadow,]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(memo.images[0]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
class DeleteMemoWidget extends StatelessWidget {
  final Memo memo;
  const DeleteMemoWidget({super.key,required this.memo});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async{
        final confirm = await showDialog<bool>(
          context:context,
          builder: (context) => AlertDialog(
            title: Text('确认删除',style: MemoStyle.titleTextStyle,),
            content: Text('确定要删除这条memo吗？',style: MemoStyle.bodyTextStyle,),
            actions:[
              TextButton(
                onPressed: ()=> Navigator.pop(context, false),
                child:  Text('取消',style: MemoStyle.dialogButtonTextStyle,),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context,true),
                child: Text('删除',style: MemoStyle.dialogButtonTextStyle,),
              ),
            ],
            shape:  RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
              backgroundColor: Colors.white,
          ),
        );
        if(confirm == true) {
          await deleteMemo(memo, () {
            print("删除成功");
            Navigator.pop(context);
          });
        }
      },
      icon: const Icon(Icons.delete_outline),
    );
  }
}

final Map<DateTime, int> heatmapData = {
  DateTime.now().subtract(Duration(days: 5)): 2,
  DateTime.now().subtract(Duration(days: 8)): 4,
  DateTime.now().subtract(Duration(days: 15)): 1,
};

class MyHeatMap extends StatelessWidget {
  // TODO: 热力图
  const MyHeatMap();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 392,
      height: 130,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            GitHubHeatmap(
              startDate: DateTime.now().subtract(const Duration(days: 29 * 7)),
              totalWeeks: 30,
              data: heatmapData,
              cellSize: 9,
              spacing: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class MemoBackButton extends StatelessWidget {
  const MemoBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 20,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/assets/back.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: InkWell(
        onTap: () {
          print("back");
          Navigator.pop(context);
        },
      ),
    );
  }
}

class MemoReminderPop extends StatelessWidget {
  final String title;
  final String content;
  final String action;
  const MemoReminderPop({super.key,required this.title,required this.content,required this.action});

  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
      title: Text(
        title,
        style: MemoStyle.titleTextStyle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        content,
        style: MemoStyle.bodyTextStyle.copyWith(
          fontSize: 16,
          color: Colors.grey[700],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Color.fromRGBO(64, 185, 222, 1),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          child: Text(action,style: MemoStyle.dialogButtonTextStyle,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
    );
  }
}
