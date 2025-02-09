import 'package:flutter/material.dart';
import 'package:memo_program/styles/memo_style.dart';
class UserAvatar extends StatelessWidget {

  const UserAvatar({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 61,
      height: 61,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: const DecorationImage(
            image: AssetImage('lib/assets/avatar.jpg'),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            MemoStyle.cardShadow,
          ]),
    );
  }
}
class UserName extends StatelessWidget {

  final TextStyle style;

  const UserName({super.key, required this.style});
  @override
  Widget build(BuildContext context) {
    return Text(
      'Lenci',
      style: style,
    );
  }
}
class UserSign extends StatelessWidget {

  final TextStyle style;
  const UserSign({super.key,required this.style});
  @override
  Widget build(BuildContext context) {
    return Text(
      '香橙味全能糕手',
      style: style,
    );
  }
}


