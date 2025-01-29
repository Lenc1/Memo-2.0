// main.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:memo_program/styles/memo_style.dart';
import 'package:memo_program/widgets/user_widget.dart';
import 'package:window_manager/window_manager.dart';
import 'config/memo_config.dart';
import 'pages/new_diary.dart';
import 'models/memo_widget.dart';
import 'pages/check_memo.dart';

import 'pages/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.setSize(const Size(470, 800) //自定义窗口大小
      );

  windowManager.setResizable(false);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Memo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Memo> _memo = [];
  Map<DateTime, int> _data = {};

  @override
  void initState() {
    _initExampleData();
    super.initState();
  }

  void _initExampleData() {
    var rng = Random();
    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < 200; i++) {
      DateTime date = today.subtract(Duration(days: i));
      _data[date] = rng.nextInt(6); // Random number between 0 and 5
    }
  }

  // 跳转到新建日记页面
  void _navigateToNewDiaryPage(BuildContext context) async {
    final newDiary = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewDiaryPage()),
    );
    if (newDiary != null) {
      setState(() {
        _memo.add(newDiary);
      });
    }
  }

  // 跳转到个人主页
  void _navigateToProfilePage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 251, 255, 1),
      body: Column(
        children: [
          Container(
            width: 392,
            height: 307,
            margin: const EdgeInsets.only(top: 22, right: 26, left: 26),
            decoration: MemoStyle.cardDecoration,
            child: Stack(
              children: [
                Container(
                  width: 253,
                  height: 73,
                  margin: const EdgeInsets.only(left: 12, top: 26, right: 121),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(242, 242, 242, 1),
                    borderRadius: BorderRadius.circular(37),
                  ),
                  child: InkWell(
                    onTap: () {
                      _navigateToProfilePage(context);
                      print('Contaner clicked!');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              top: 6, left: 8, right: 14, bottom: 7),
                          child: const UserAvatar(),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              UserName(
                                  style: MemoStyle.titleTextStyle.copyWith(
                                fontWeight: FontWeight.w900,
                              )),
                              const SizedBox(
                                height: 4,
                              ),
                              const Text(
                                '已使用 Memo 280 天',
                                style: TextStyle(
                                  fontFamily: 'SourceHanSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromRGBO(117, 117, 117, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 65, left: 320),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: MemoConfig.showHeatMap,
                    builder: (context, showHeatMap, child) {
                      return IconButton(
                        onPressed: () {
                          // 切换 showHeatMap 状态
                          MemoConfig.toggleHeatMap();
                        },
                        icon: Icon(
                          showHeatMap ? Icons.vertical_align_top : Icons.vertical_align_bottom,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  margin: EdgeInsets.only(top: 127),
                  child: NewMemoWidget(
                      onPressed: () => _navigateToNewDiaryPage(context)),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder(
              valueListenable: MemoConfig.showHeatMap,
              builder: (context, showHeatMap, child) {
                if (showHeatMap) {
                  return const MyHeatMap();
                }
                else{
                  return Container();
                }
              },
              ),
          Expanded(
            child: ListView.builder(
              itemCount: _memo.length,
              itemBuilder: (context, index) {
                final memo = _memo[_memo.length - index - 1];
                return Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 392,
                    height: 156,
                    margin:
                        const EdgeInsets.only(bottom: 16, left: 20, right: 20),
                    decoration: MemoStyle.cardDecoration,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemoCheckPage(memo: memo),
                          ),
                        );
                      },
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MemoCheckPage(memo: memo),
                            ),
                          );
                        },
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
                                  top: 58, left: 30, right: 144),
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
                              margin: const EdgeInsets.only(top: 16, left: 260),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    MemoStyle.cardShadow,
                                  ]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  memo.images[0],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
