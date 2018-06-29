import 'package:meta/meta.dart';

class Item {
  final String id;
  final String title;
  final String content;
  final DateTime time;

  Item({
    this.id,
    @required this.title,
    @required this.content,
    @required this.time,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'time': time,
      };

  @override
  String toString() =>
      'Item{id: $id, title: $title, content: $content, time: $time}';
}

enum OrderBy { titleAsc, timeAsc, titleDesc, timeDesc }
