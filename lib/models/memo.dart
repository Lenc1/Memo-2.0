import 'dart:io';

class Memo {
  String title;
  String content;
  List<File> images;
  String created_at;

  Memo(
      {required this.title,
        required this.content,
        required this.images,
        required this.created_at
      });
  Map<String, dynamic> toJson(){
    return{
      'title': title,
      'content': content,
      'images': images.map((image) => image.path).toList(), // 存储图片的路径
      'created_at': created_at,
    };
  }
  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      title: json['title'],
      content: json['content'],
      images: List<File>.from(json['images'].map((path) => File(path))),
      created_at: json['created_at'],
    );
  }
}