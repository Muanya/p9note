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
      DatabaseProvider.COLUMN_NOTE_TITLE: title,
      DatabaseProvider.COLUMN_NOTE_BODY: body,
      DatabaseProvider.COLUMN_NOTE_COLOR: noteColor.value,
      DatabaseProvider.COLUMN_NOTE_EDITED:
          dateLastEdited.millisecondsSinceEpoch,
      DatabaseProvider.COLUMN_CREATED: dateCreated.millisecondsSinceEpoch,
    };
  }

  /// deserialise object when reading from database
  Note.fromMap(Map<String, dynamic> map) {
    id = map[DatabaseProvider.COLUMN_ID];
    title = map[DatabaseProvider.COLUMN_NOTE_TITLE];
    body = map[DatabaseProvider.COLUMN_NOTE_BODY];
    dateCreated = DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseProvider.COLUMN_CREATED]);
    dateLastEdited = DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseProvider.COLUMN_NOTE_EDITED]);
    noteColor = Color(map[DatabaseProvider.COLUMN_NOTE_COLOR]);
  }

  @override
  String toString() {
    return 'Note{'
        '${DatabaseProvider.COLUMN_ID}: $id, '
        '${DatabaseProvider.COLUMN_NOTE_TITLE}: $title, '
        '${DatabaseProvider.COLUMN_NOTE_BODY}: $body }';
  }
}

class NoteCategory {
  late int id;
  late String name;
  late Color categoryColor;
  DateTime dateCreated = DateTime.now();

  NoteCategory({
    required this.id,
    required this.name,
    required this.categoryColor,
});

  Map<String, dynamic> toMap() {
    return {
      DatabaseProvider.COLUMN_CATEGORY_NAME: name,
      DatabaseProvider.COLUMN_CATEGORY_COLOR: categoryColor.value,
      DatabaseProvider.COLUMN_CREATED: dateCreated.millisecondsSinceEpoch,
    };
  }

  /// deserialise object when reading from database
  NoteCategory.fromMap(Map<String, dynamic> map) {
    id = map[DatabaseProvider.COLUMN_ID];
    name = map[DatabaseProvider.COLUMN_CATEGORY_NAME];
    categoryColor = Color(map[DatabaseProvider.COLUMN_CATEGORY_COLOR]);
    dateCreated = DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseProvider.COLUMN_CREATED]);
  }
}

class Joint {
  late int noteID;
  late int categoryID;

  Joint({
    required this.noteID,
    required this.categoryID,
});

  Map<String, dynamic> toMap() {
    return {
      DatabaseProvider.COLUMN_CATEGORY_ID: categoryID,
      DatabaseProvider.COLUMN_NOTE_ID: noteID,
    };
  }

  /// deserialise object when reading from database
  Joint.fromMap(Map<String, dynamic> map) {
    noteID = map[DatabaseProvider.COLUMN_NOTE_ID];
    categoryID = map[DatabaseProvider.COLUMN_CATEGORY_ID];
  }
}
