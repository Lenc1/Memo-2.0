// main.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'new_diary.dart';
import 'dart:io';

void main() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 251, 255, 1),
      body: Column(
        children: [
          Container(
            width: 392,
            height: 307,
            margin:
                const EdgeInsets.only(top: 22,right: 26,left: 26),
            decoration: BoxDecoration(
              color: Colors.white, // 设置背景颜色为白色
              borderRadius: BorderRadius.circular(16), // 设置圆角
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    print('Contaner clicked!');
                  },
                  child: Container(
                    width: 253,
                    height: 73,
                    margin:
                        const EdgeInsets.only(left: 12, top: 26, right: 121),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(242, 242, 242, 1),
                      borderRadius: BorderRadius.circular(37),
                    ),
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
                          ),
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
                  child: GestureDetector (
                    onTap: (){
                      print('open');
                      _navigateToNewDiaryPage(context);
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
                          borderRadius: BorderRadius.circular(27),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(left: 54, top: 16),
                          child: const Text(
                            '添加Memo',
                            style: TextStyle(
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
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 16, left: 22, bottom: 68),
                          child: const Text(
                            '2025.01.26',
                            style: TextStyle(
                              fontSize: 24,
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
                        margin: const EdgeInsets.only(top: 5, left: 306),
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('lib/assets/tag.png'))),
                      ),
                      Container(
                        width: 60,
                        height: 70,
                        margin: const EdgeInsets.only(top: 73, left: 281),
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('lib/assets/pen.png'))),
                      ),
                    ],
                  ),
                ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 392,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _diaries.length,
              itemBuilder: (context, index) {
                final diary = _diaries[index];
                return ListTile(
                  title: Text('日记 #${index + 1}'),
                  subtitle: Text(diary.content),
                  onTap: () {
                    // 查看日记详细内容
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiaryDetailPage(diary: diary),
                      ),
                    );
                  },
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
