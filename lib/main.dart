// main.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:window_manager/window_manager.dart';
import 'pages/new_diary.dart';
import 'models/memo_weiget.dart';

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
  List<DiaryEntry> _diaries = [];
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
        _diaries.add(newDiary);
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
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
                          width: 61,
                          height: 61,
                          margin: const EdgeInsets.only(
                              top: 6, left: 8, right: 14, bottom: 7),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage('lib/assets/avator.jpg'),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.25),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                              ]),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Lenci',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(41, 41, 41, 1),
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
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
                const SizedBox(height: 24),
                NewMemoWidget(
                    onPressed: () => _navigateToNewDiaryPage(context)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const MyHeatMap(),
          Expanded(
            // TODO: 日记列表美化
            child: ListView.builder(
              itemCount: _diaries.length,
              itemBuilder: (context, index) {
                final diary = _diaries[index];
                return Align(
                  // 使用 Align 来控制宽度
                  alignment: Alignment.center, // 将容器居中
                  child: Container(
                    width: 392,
                    // 固定宽度
                    height: 156,
                    margin:
                        const EdgeInsets.only(bottom: 16, left: 20, right: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiaryDetailPage(diary: diary),
                          ),
                        );
                      },
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DiaryDetailPage(diary: diary),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 29, left: 30),
                              child: Text(
                                '日记 #${index + 1}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color.fromRGBO(74, 74, 74, 1),
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
                                diary.content.length > 10
                                    ? '${diary.content.substring(0, 10)}...'
                                    : diary.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              width: 115,
                              height: 115,
                              margin: const EdgeInsets.only(top: 16, left: 260),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.25),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                    ),
                                  ]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  diary.images[0],
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

class DiaryDetailPage extends StatelessWidget {
  final DiaryEntry diary;

  const DiaryDetailPage({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日记详情'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              diary.content,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            if (diary.images.isNotEmpty) ...[
              const Text('日记图片：'),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: diary.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Image.file(
                        diary.images[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
