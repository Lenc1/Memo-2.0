import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../config/memo_config.dart';
import '../models/memo.dart';
import '../services/memo_services.dart';
import '../styles/memo_style.dart';
import 'package:path/path.dart' as path;

class SmartHeatMap extends StatelessWidget {
  const SmartHeatMap({super.key});

  Future<Map<DateTime, int>> _fetchHeatmapData() async {
    final Map<DateTime, int> dataset = {};
    final directory = await PathManager.getSavePath();
    final dir = Directory(directory);

    final files = await dir.list().where((f) => f.path.endsWith('.json')).toList();

    for (var file in files) {
      try {
        final content = await File(file.path).readAsString();
        final memo = Memo.fromJson(jsonDecode(content));
        DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(memo.milliseconds));
        DateTime dayKey = DateTime(date.year, date.month, date.day);
        dataset[dayKey] = (dataset[dayKey] ?? 0) + 1;
      } catch (e) {
        continue;
      }
    }
    return dataset;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<DateTime, int>>(
      future: _fetchHeatmapData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
          ),
          child: HeatMap(
            datasets: snapshot.data,
            colorMode: ColorMode.opacity,
            showColorTip: false,
            scrollable: true,
            borderRadius: 3,
            size: 9,
            margin: const EdgeInsets.all(1.8),
            fontSize: 8,
            colorsets: {
              1: const Color(0xFF8BE1E4),
              3: const Color(0xFF6FBEC9),
              5: const Color(0xFF23579A),
            },
            startDate: DateTime.now().subtract(const Duration(days:77)),
            endDate: DateTime.now(),
          ),
        );
      },
    );
  }
}
class NewMemoWidget extends StatelessWidget {
  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  const NewMemoWidget({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth,
      height: 156,
      margin: const EdgeInsets.only(top: 0, right: 11, left: 12),
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
            Positioned(
              right: screenWidth > 440 ? 180 : screenWidth - 250,
              child: Container(
                width: 180,
                height: 54,
                margin: const EdgeInsets.only(top: 48),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(156, 204, 219, 1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('lib/assets/addition_fill.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      screenWidth < 410 ? '' : '添加Memo',
                      style: const TextStyle(
                        fontFamily: 'SourceHanSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              right: 0,
                child: SmartHeatMap(),
            ),
            // Positioned(
            //   right: 0,
            //   child: Container(
            //     width: 196,
            //     height: 130,
            //     margin: const EdgeInsets.only(top: 13, right: 12, bottom: 13),
            //     decoration: BoxDecoration(
            //       color: const Color.fromRGBO(255, 255, 255, 1),
            //       borderRadius: BorderRadius.circular(18),
            //       boxShadow: const [
            //         BoxShadow(
            //           color: Color.fromRGBO(0, 0, 0, 0.25),
            //           offset: Offset(0, 2),
            //           blurRadius: 4,
            //           spreadRadius: 0,
            //         ),
            //       ],
            //     ),
            //     child: Container(
            //       margin: const EdgeInsets.only(top: 24, left: 22, bottom: 68),
            //       child: Text(
            //         _getCurrentDate(),
            //         style: const TextStyle(
            //           fontSize: 22,
            //           fontWeight: FontWeight.w900,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            Positioned(
              right: 20,
              child: Container(
                width: 35,
                height: 35,
                margin: const EdgeInsets.only(top: 5),
                decoration: const BoxDecoration(
                  image:
                      DecorationImage(image: AssetImage('lib/assets/tag.png')),
                ),
              ),
            ),
            // Positioned(
            //   right: 30,
            //   child: Container(
            //     width: 60,
            //     height: 70,
            //     margin: const EdgeInsets.only(top: 73),
            //     decoration: const BoxDecoration(
            //       image:
            //           DecorationImage(image: AssetImage('lib/assets/pen.png')),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class MemoListViewBuilder extends StatelessWidget {
  final List<Memo> memos;
  final void Function(Memo) onPressed;
  final String imgPath;
  const MemoListViewBuilder({
    super.key,
    required this.memos,
    required this.onPressed,
    required this.imgPath,
  });
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return ListView.builder(
      padding: EdgeInsets.zero, //默认会留出刘海空间，所以强制设置0
      itemCount: memos.length,
      itemBuilder: (context, index) {
        final memo = memos[memos.length - index - 1];
        return Container(
          padding: const EdgeInsets.only(top: 0, bottom: 16),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (context) async {
                    await CURDManager.handleDeleteMemo(
                      context: context,
                      memo: memo,
                      onSuccess: MemoConfig.toggleRefresh,
                    );
                  },
                  backgroundColor: const Color.fromRGBO(255, 73, 73, 1),
                  //foregroundColor: Colors.white,
                  //icon: Icons.delete_rounded,
                  label: '删除', //TODO: 改成变量，方便全局语言修改
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(16)),
                  autoClose: false,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: screenWidth,
                  height: 156,
                  decoration: MemoStyle.cardDecoration,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onPressed(memo),
                    child: Stack(
                      children: [
                        // 标题
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
                        // 分割线
                        Container(
                          margin: const EdgeInsets.only(
                              top: 58, left: 30, right: 154),
                          child: const Divider(
                            height: 1,
                            color: Colors.grey,
                            thickness: 1,
                          ),
                        ),
                        // 内容
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
                        // 创建日期
                        Container(
                          margin: const EdgeInsets.only(top: 105, left: 31),
                          child: Text(
                            '${memo.created_at.substring(0, 10)}   ${memo.created_at.substring(11,19)}' ,
                            style: MemoStyle.bodyHintTextStyle.copyWith(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 25,
                          child: Container(
                            width: 115,
                            height: 115,
                            margin: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [MemoStyle.cardShadow],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: memo.images.isEmpty
                                  ? Container(
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'lib/assets/memo_placeholder.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Image.file(
                                      File(path.join(
                                          imgPath, 'pictures', memo.images[0])),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
  const DeleteMemoWidget({super.key, required this.memo});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await CURDManager.handleDeleteMemo(
            context: context,
            memo: memo,
            onSuccess: () {
              Navigator.pop(context);
            });
      },
      icon: const Icon(Icons.delete_outline),
    );
  }
}

Future<bool?> showSavePicDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('保存图片', style: MemoStyle.titleTextStyle),
      content: Text('是否要保存此图片？', style: MemoStyle.bodyTextStyle),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false); // 关闭弹窗
          },
          child: Text('取消', style: MemoStyle.dialogButtonTextStyle),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true); // 关闭弹窗
          },
          child: Text('保存', style: MemoStyle.dialogButtonTextStyle),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
    ),
  );
}

Future<bool?> showCompressDialog(BuildContext context) async {
  return showDialog<bool>(
      context: context,
      builder: (context) => const MemoBoolAskPop(
          title: '导出确认',
          content: '导出后是否保留现有memo',
          action1: '保留',
          action2: '清空'));
}

Future<bool?> showDeleteDialog(BuildContext context) async {
  return showDialog<bool>(
      context: context,
      builder: (context) => const MemoBoolAskPop(
          title: '删除确认', content: '是否删除这条memo？', action1: '取消', action2: '删除'));
}

class MemoBackButton extends StatelessWidget {
  const MemoBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: Image.asset(
        'lib/assets/back.png',
        width: 22,
        height: 20,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class MemoBoolAskPop extends StatelessWidget {
  final String title;
  final String content;
  final String action1;
  final String action2;
  const MemoBoolAskPop(
      {super.key,
      required this.title,
      required this.content,
      required this.action1,
      required this.action2});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
            foregroundColor: const Color.fromRGBO(64, 185, 222, 1),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          child: Text(
            action1,
            style: MemoStyle.dialogButtonTextStyle,
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromRGBO(64, 185, 222, 1),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          child: Text(
            action2,
            style: MemoStyle.dialogButtonTextStyle.copyWith(color: Colors.red),
          ),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class MemoReminderPop extends StatelessWidget {
  final String title;
  final String content;
  final String action;
  const MemoReminderPop(
      {super.key,
      required this.title,
      required this.content,
      required this.action});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
            foregroundColor: const Color.fromRGBO(64, 185, 222, 1),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          child: Text(
            action,
            style: MemoStyle.dialogButtonTextStyle,
          ),
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
