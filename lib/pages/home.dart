import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:memo_program/models/memo.dart';
import 'package:memo_program/styles/memo_style.dart';
import 'package:memo_program/widgets/user_widget.dart';
import 'package:memo_program/services/memo_services.dart';

//import 'package:path_provider/path_provider.dart';
import '../config/memo_config.dart';
import 'todo_page.dart';
import '../widgets/memo_widget.dart';
import 'check_memo.dart';
import 'config.dart';
import 'profile.dart';
import 'add_memo.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//TODO 刷新，imgPath地址无法实时更新
class _MyHomePageState extends State<MyHomePage> {
  final List<Memo> _memo = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final FocusNode _searchFocus = FocusNode();//用于拦截加载时Focus到搜索框
  String imgPath = '';
  @override
  void initState() {
    _loadSavedMemos();
    super.initState();
  }

  void reloadMemo() async {
    _memo.clear();
    await _loadSavedMemos();
    setState(() {});
  }

  Future<void> _loadSavedMemos() async {
    final directory = await PathManager.getSavePath();
    final dir = Directory(directory);
    // 获取文件列表
    final files = await dir.list()
        .where((file) => file.path.endsWith('.json') && file.path.contains('memo_'))
        .toList();

    List<Memo> fetchedMemos = [];
    for (var file in files) {
      final content = await File(file.path).readAsString();
      fetchedMemos.add(Memo.fromJson(jsonDecode(content)));
    }

    setState(() {
      final newMemos = fetchedMemos.where((m) => !_memo.any((existing) => existing.created_at == m.created_at)).toList();
      _memo.removeWhere((existing) => !fetchedMemos.any((m) => m.created_at == existing.created_at));
      _memo.addAll(newMemos);
      _memo.sort((a, b) => a.created_at.compareTo(b.created_at));
    });
  }

  void _navigateToCheckMemoPage(BuildContext context, Memo memo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MemoCheckPage(
                memo: memo,
                imgPath: imgPath,
              )),
    ).then((_) => {reloadMemo()});
  }
  void _navigateToNewDiaryPage(BuildContext context) async {
    final newDiary = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewDiaryPage(memo: null)),
    );
    if (newDiary != null) {
      setState(() {
        _memo.add(newDiary);
      });
    }
  }
  void _navigateToConfigPage(BuildContext context) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ConfigPage(),
        transitionDuration: const Duration(milliseconds: 300), // 动画时长
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Offset(-1.0, 0.0) 表示从左侧屏幕外开始
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    ).then((_) => reloadMemo());
  }
  void _navigateToProfilePage(BuildContext context) async {
    await Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ProfilePage()))
        .then((_) => {reloadMemo()});
  }
  void _navigateToTodoPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TodoPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onHorizontalDragEnd: (details){
        if(details.primaryVelocity !> 100){
          _navigateToConfigPage(context);
        }
      },
      child: Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(240, 251, 255, 1),
      body: Stack(children: [
          Column(
          children: [
            Container(
              width: screenWidth - 30,
              height: 307,
              margin: const EdgeInsets.only(top: 50),
              decoration: MemoStyle.cardDecoration,
              child: Stack(
              children: [
                Container(
                  height: 73,
                  margin: const EdgeInsets.only(left: 12, top: 26, right: 121),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(242, 242, 242, 1),
                    borderRadius: BorderRadius.circular(37),
                  ),
                  child: InkWell(
                    onTap: () {
                      _navigateToProfilePage(context);
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
                            const SizedBox(height: 10),
                            UserName(
                              style: MemoStyle.titleTextStyle.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              screenWidth > 370 ? '已使用 Memo 280 天' : '',
                              style: const TextStyle(
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
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.only(top: 127),
                  child: NewMemoWidget(
                      onPressed: () => _navigateToNewDiaryPage(context)),
                ),
                // TODO 按钮 - 右上角
                Positioned(
                  right: 24,
                  top: 40,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _navigateToTodoPage(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [MemoStyle.cardShadow],
                      ),
                      child: const Icon(
                        Icons.checklist_rounded,
                        color: Color.fromRGBO(64, 185, 222, 1),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _memo.isNotEmpty
                  ? Align(
                  alignment: Alignment.topCenter,
                  child: ValueListenableBuilder(
                      valueListenable: MemoConfig.refresh,
                      builder: (context, refresh, child) {
                        if (refresh == false) {
                          reloadMemo();
                          MemoConfig.toggleRefresh();
                        }
                        return MemoListViewBuilder(
                          memos: _memo,
                          imgPath: imgPath,
                          onPressed: (memo) =>
                              _navigateToCheckMemoPage(context, memo),
                        );
                      }))
                  : Container(
                  width: screenWidth - 30,
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 1),
                      borderRadius: BorderRadius.circular(18)),
                  child: Container(
                    width: screenWidth * 0.8,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                'lib/assets/nomemo_placehoder.png'))),
                  )),
            ),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: TextField(
                focusNode: _searchFocus,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: Colors.blueGrey,
                decoration: InputDecoration(
                  hintText: '搜索标题或内容...',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.blueGrey),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                onChanged: (query) {
                  // 搜索逻辑
                },
                onTapOutside: (event) {
                  // 点击外部自动收起键盘并取消选中
                  FocusScope.of(context).unfocus();
                },
              ),
              ),
            ),
          ],
      ),
    ),
      );
  }
}
