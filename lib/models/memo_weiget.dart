// my_button.dart
import 'package:flutter/material.dart';
import 'heat_map.dart';
import '../pages/new_diary.dart';

class NewMemoWidget extends StatelessWidget {
  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  const NewMemoWidget({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
                margin: const EdgeInsets.only(top: 16, left: 22, bottom: 68),
                child: Text(
                  _getCurrentDate(),
                  style: const TextStyle(
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
                  image:
                      DecorationImage(image: AssetImage('lib/assets/tag.png'))),
            ),
            Container(
              width: 60,
              height: 70,
              margin: const EdgeInsets.only(top: 73, left: 281),
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

final Map<DateTime, int> heatmapData = {
  DateTime.now().subtract(Duration(days: 5)): 2,
  DateTime.now().subtract(Duration(days: 8)): 4,
  DateTime.now().subtract(Duration(days: 15)): 1,
};

class MyHeatMap extends StatelessWidget {
  const MyHeatMap();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 392,
      height: 130,
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          // TODO: 热力图
          children: [
            GitHubHeatmap(
              startDate: DateTime.now().subtract(const Duration(days: 20 * 7)),
              totalWeeks: 30,
              // 显示列
              data: heatmapData,
              cellSize: 9,
              // 单元格size
              spacing: 1, // 间隔
            )
          ],
        ),
      ),
    );
  }
}
