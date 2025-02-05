import 'dart:io';

class Memo {
  String title;
  String content;
  List<String> images;  // 存储图片路径
  String created_at;
  String milliseconds;

  Memo({
    required this.title,
    required this.content,
    required this.images,
    required this.created_at,
    required this.milliseconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'images': images,
      'created_at': created_at,
      'milliseconds': milliseconds,
    };
  }

  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      title: json['title'],
      content: json['content'],
      images: List<String>.from(json['images']),
      created_at: json['created_at'],
      milliseconds: json['milliseconds'],
    );
  }
}
