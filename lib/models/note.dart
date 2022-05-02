import 'dart:ui';
import 'package:p9note/models/db_provider.dart';

class Note {
  late int id;
  late String title;
  late String body;
  late Color noteColor;
  late DateTime dateLastEdited;
  DateTime dateCreated = DateTime.now();

  Note({
    required this.id,
    this.body = "",
    this.title = "",
    required this.dateLastEdited,
    required this.noteColor,
  });

  Map<String, dynamic> toMap() {
    return {
      // DatabaseProvider.COLUMN_ID: id,
      DatabaseProvider.COLUMN_TITLE: title,
      DatabaseProvider.COLUMN_BODY: body,
      DatabaseProvider.COLUMN_COLOR: noteColor.value,
      DatabaseProvider.COLUMN_EDITED: dateLastEdited.millisecondsSinceEpoch,
      DatabaseProvider.COLUMN_CREATED: dateCreated.millisecondsSinceEpoch,
    };
  }

  /// deserialise object when reading from database
  Note.fromMap(Map<String, dynamic> map) {
    id = map[DatabaseProvider.COLUMN_ID];
    title = map[DatabaseProvider.COLUMN_TITLE];
    body = map[DatabaseProvider.COLUMN_BODY];
    dateCreated = DateTime.fromMillisecondsSinceEpoch(map[DatabaseProvider.COLUMN_CREATED]);
    dateLastEdited = DateTime.fromMillisecondsSinceEpoch(map[DatabaseProvider.COLUMN_EDITED]);
    noteColor = Color(map[DatabaseProvider.COLUMN_COLOR]);
  }

  @override
  String toString() {
    return 'Note{'
        '${DatabaseProvider.COLUMN_ID}: $id, '
        '${DatabaseProvider.COLUMN_TITLE}: $title, '
        '${DatabaseProvider.COLUMN_BODY}: $body }';
  }
}
