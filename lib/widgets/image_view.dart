import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerBuilder extends StatelessWidget {
  final String path;
  const ImageViewerBuilder({super.key,required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
        color:Colors.black.withOpacity(0.7),
      child: PhotoView(
        imageProvider: FileImage(File(path)),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered*2,
        enablePanAlways: true,
        backgroundDecoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
      ),
    );
  }
}
