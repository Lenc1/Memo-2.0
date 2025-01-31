import 'dart:io';

import 'package:flutter/material.dart';

class ImageViewerBuilder extends StatelessWidget {
  final String path;
  const ImageViewerBuilder({super.key,required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
        color:Colors.black.withOpacity(0.7),
        child: Center(
            child:Image.file(
              File(path),
              fit:BoxFit.contain,
            )
        )
    );
  }
}
