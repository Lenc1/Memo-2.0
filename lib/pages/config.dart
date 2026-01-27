import 'package:flutter/material.dart';
import 'package:memo_program/config/memo_config.dart'; // 确保路径正确
import 'package:memo_program/styles/memo_style.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromRGBO(240, 251, 255, 1),
      appBar: AppBar(
        title: const Text('系统设置', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: MemoConfig.updateTimeOnEdit,
                builder: (context, updateTime, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent, // 去掉水波纹
                      highlightColor: Colors.transparent, // 去掉点击高亮
                      hoverColor: Colors.transparent, // 去掉鼠标悬停（针对全平台更稳妥）
                    ),
                    child: SwitchListTile(
                    title: const Text('编辑后更新时间',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    subtitle: Text(updateTime ? '保存时将更新为最新时间' : '始终保留初次创建时间',
                        style: const TextStyle(fontSize: 12)),
                    secondary: const Icon(Icons.update_rounded, color: Colors.blueAccent),
                    value: updateTime,
                    activeColor: const Color.fromRGBO(77, 175, 213, 1.0),
                    onChanged: (bool value) {
                      MemoConfig.toggleUpdateTime();
                    },
                    ),
                  );
                },
              ),
              //const Divider(indent: 20, endIndent: 20),
            ],
          ),
        ),
      ),
    );
  }
}