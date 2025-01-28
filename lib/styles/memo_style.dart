import 'package:flutter/material.dart';

class MemoStyle{
  // 正文样式
  static TextStyle get bodyTextStyle => const TextStyle(
    fontFamily: 'SourceHanSans',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Color.fromRGBO(46, 46, 46, 1),
  );
  // 正文提示样式
  static TextStyle get bodyHintTextStyle => const TextStyle(
    fontFamily: 'SourceHanSans',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Color.fromRGBO(130, 130, 130, 1),
  );
  //标题样式
  static TextStyle get titleTextStyle => const TextStyle(
    fontFamily: 'SourceHanSans',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color.fromRGBO(46, 46, 46, 1),
  );
  // 标题提示样式
  static TextStyle get titleHintTextStyle => const TextStyle(
    fontFamily: 'SourceHanSans',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Color.fromRGBO(130, 130, 130, 1),
  );
  // 卡片阴影
  static BoxShadow get cardShadow => const BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.25),
    offset: Offset(0, 2),
    blurRadius: 4,
    spreadRadius: 0,
  );
  // 卡片装饰
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
  );
  // Memo主背景颜色
  static Color get memoBackGroundColor => const Color.fromRGBO(240, 251, 255, 1);
}