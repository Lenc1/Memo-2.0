
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:memo_program/config/config_list.dart';
import 'package:memo_program/pages/config.dart';
import 'package:memo_program/services/memo_services.dart';
import 'package:memo_program/styles/memo_style.dart';
import 'package:memo_program/widgets/user_widget.dart';

import '../widgets/memo_widget.dart';

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
              margin: const EdgeInsets.only(top: 50),
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
                            image: AssetImage('lib/assets/backFile.png'),
                            fit: BoxFit.cover)),
                  ), // 底层黑文件夹
                  Container(
                    margin: const EdgeInsets.only(top: 37, left: 32),
                    child: const MemoBackButton(),
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
                    margin: const EdgeInsets.only(top: 54, left: 256),
                    child: const UserAvatar(),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 99, left: 56),
                    child: Text('昵称:',style: MemoStyle.bodyHintTextStyle.copyWith(
                        color: const Color.fromRGBO(82, 82, 82, 1),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 128, left: 56),
                    child: Text('性别:',style: MemoStyle.bodyHintTextStyle.copyWith(
                        color: const Color.fromRGBO(82, 82, 82, 1),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top:130,left:107),
                    child: const Icon(Icons.male,color: Color.fromRGBO(122, 184, 245, 1),),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top:164,left:56),
                    child: UserSign(style: MemoStyle.bodyHintTextStyle),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 99,left: 107),
                    child: UserName(style: MemoStyle.titleTextStyle),
                  )// 头像
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: 392,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.builder(
                  itemCount: ConfigList.configList.length,
                  itemBuilder: (context, index) {
                    final config = ConfigList.configList[index];
                    return Container(
                      padding: const EdgeInsets.only(top: 18, bottom: 16),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          height: 30,
                          child: InkWell(
                            onTap: () async {
                              switch (config.configRoute) {
                                case '1':
                                  showDialog(context: context, builder: (BuildContext context){
                                    return const MemoReminderPop(title: '提醒', content: '当前内容未完成', action: '确认');
                                  });
                                      break;
                                case '2':
                                  String? result = await PathManager.pickPath();
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return MemoReminderPop(title: '提醒', content: result, action: '确认',
                                        );
                                      });
                                  break;
                                case '3':
                                  final confirm = await showCompressDialog(context);
                                  String? result =
                                      await PathManager.pressMemo(confirm);
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return MemoReminderPop(title: '提醒', content: result, action: '确认',
                                        );
                                      });
                                  break;
                                case '4':
                                  String? result =
                                  await PathManager.extractMemo();
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return MemoReminderPop(title: '提醒', content: result, action: '确认',
                                        );
                                      });
                                  break;
                                case '5':
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ConfigPage()),
                                  );
                                  break;
                                default:
                                  print("无效的路径");
                              }
                            },
                            child: Row(
                              children: [
                                const SizedBox(width: 29),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                    image: Svg(config.configIcon),
                                    fit: BoxFit.cover,
                                  )),
                                ),
                                const SizedBox(width: 17),
                                Text(
                                  config.configName,
                                  style: MemoStyle.bodyTextStyle.copyWith(
                                    color: const Color.fromRGBO(51, 51, 51, 1),
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
            )
          ],
        ),
      ),
    );
  }
}
