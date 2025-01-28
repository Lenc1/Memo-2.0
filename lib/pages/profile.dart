import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 251, 255, 1),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Container(
              width: 392,
              height: 307,
              margin: const EdgeInsets.only(top: 22, right: 26, left: 26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Container(
                    width: 352,
                    height: 218,
                    margin: const EdgeInsets.only(top: 32, left: 14),
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('lib/assets/backfile.png'),
                            fit: BoxFit.cover)),
                  ), // 底层黑文件夹
                  Container(
                    width: 22,
                    height: 20,
                    margin: const EdgeInsets.only(top: 37, left: 32),
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
                  ), // 返回按钮
                  Container(
                    width: 310,
                    height: 145,
                    margin: const EdgeInsets.only(top: 84, left: 35),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                  ), // 白底矩形
                  Container(
                      width: 287,
                      height: 58,
                      margin: EdgeInsets.only(top: 158, left: 46),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(247, 247, 247, 1),
                        borderRadius: BorderRadius.circular(12),
                      )), // 灰底矩形
                  Container(
                    width: 61,
                    height: 61,
                    margin: const EdgeInsets.only(top: 54, left: 256),
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
                  ), // 头像
                ],
              ),
            ),
            Container(
              width: 392,
              height: 300,
              margin: EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
