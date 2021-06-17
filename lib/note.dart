import 'package:meta/meta.dart';

class Notes {
  Notes({
    @required this.id,
    @required this.title,
    @required this.description,
  });
  final String id;

  final String title, description;

  factory Notes.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    final String title = data['title'];
    final String description = data['description'];
    final String id = data['id'];

    return Notes(title: title, description: description, id: id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}
