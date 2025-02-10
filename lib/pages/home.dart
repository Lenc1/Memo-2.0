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
import '../widgets/memo_widget.dart';
import 'check_memo.dart';
import 'profile.dart';
import 'add_memo.dart';

class MyHomePage extends StatefulWidget {

  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Memo> _memo = [];
  final Map<DateTime, int> _data = {};

  @override
  void initState() {
    _initExampleData();
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
    final files = await dir
        .list()
        .where((file) => file.path.endsWith('.json') && file.path.contains('memo_'))
        .toList();

    for (var file in files) {
      final content = await File(file.path).readAsString();
      final json = jsonDecode(content);
      final memo = Memo.fromJson(json);
      if (!_memo.any((m) => m.created_at == memo.created_at)) {
        setState(() {
          _memo.add(memo);
        });
      }
    }
    _memo.sort((a, b) => a.created_at.compareTo(b.created_at));
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

  void _navigateToCheckMemoPage(BuildContext context, Memo memo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MemoCheckPage(memo: memo)),
    ).then((_) => {reloadMemo()});
  }

  void _navigateToNewDiaryPage(BuildContext context) async {
    final newDiary = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const NewDiaryPage(memo: null)),
    );
    if (newDiary != null) {
      setState(() {
        _memo.add(newDiary);
      });
    }
  }

  void _navigateToProfilePage(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage())
    ).then((_) => {reloadMemo()});
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromRGBO(240, 251, 255, 1),
      body: Column(
        children: [
          // Container(
          //   margin: const EdgeInsets.only(top: 10,left: 20),
          //   child: Text('Width:$screenWidth~memo:${_memo.length}'),
          // ),
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
                                screenWidth>370?'已使用 Memo 280 天':'',
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
                Positioned(
                  right: 25,
                    child: Container(
                  margin: const EdgeInsets.only(top: 65),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: MemoConfig.showHeatMap,
                    builder: (context, showHeatMap, child) {
                      return IconButton(
                        onPressed: () {
                          reloadMemo();
                          MemoConfig.toggleHeatMap();
                        },
                        icon: Icon(
                          showHeatMap
                              ? Icons.vertical_align_top
                              : Icons.vertical_align_bottom,
                        ),
                      );
                    },
                  ),
                )
                ),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.only(top: 127),
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
              } else {
                return Container();
              }
            },
          ),
          Expanded(

            child:_memo.isNotEmpty
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
                        onPressed: (memo) =>
                            _navigateToCheckMemoPage(context, memo),
                      );
                    }))
                :Container(
              width: screenWidth-30,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  borderRadius: BorderRadius.circular(18)
                ),
                child: Container(
                width: screenWidth*0.8,
                decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage('lib/assets/nomemo_placehoder.png'))
              ),
            ))
            ,
          ),
        ],
      ),
    );
  }
}
