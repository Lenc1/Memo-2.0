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
        child: Container(
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
                margin: const EdgeInsets.only(top: 32,left: 14),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/assets/backfile.png'),
                    fit: BoxFit.cover
                  )
                ),
              ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
