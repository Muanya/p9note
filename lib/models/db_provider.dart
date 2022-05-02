import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'note.dart';

class DatabaseProvider {
  static const String TABLE_NOTE = 'note_table';
  static const String COLUMN_ID = 'id';
  static const String COLUMN_TITLE = 'title';
  static const String COLUMN_BODY = 'body';
  static const String COLUMN_CREATED = 'date_created';
  static const String COLUMN_EDITED = 'date_last_edited';
  static const String COLUMN_COLOR = 'note_color';
  static const String DB_NAME = 'notesDb.db';

  DatabaseProvider._();

  static final db = DatabaseProvider._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    String dbPath = join(await getDatabasesPath(), DB_NAME);
    return await openDatabase(dbPath, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
        "CREATE TABLE $TABLE_NOTE ("
        "$COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$COLUMN_TITLE BLOB,"
        "$COLUMN_BODY BLOB, $COLUMN_CREATED INTEGER, $COLUMN_EDITED INTEGER, $COLUMN_COLOR INTEGER"
        ")",
      );
    });
  }

  Future<List<Note>> getNotes() async {
    final db = await database;

    var notes = await db.query(TABLE_NOTE,
        columns: [
          COLUMN_ID,
          COLUMN_TITLE,
          COLUMN_BODY,
          COLUMN_CREATED,
          COLUMN_EDITED,
          COLUMN_COLOR
        ],
        orderBy: '$COLUMN_ID desc');

    List<Note> noteList = [];

    for (var element in notes) {
      // deserialize each element
      Note n = Note.fromMap(element);
      noteList.add(n);
    }

    return noteList;
  }

  Future<List<Note>> getNotesWithTitleKeywords(String keywords) async {
    final db = await database;

    var notes = await db.query(TABLE_NOTE,
        columns: [
          COLUMN_ID,
          COLUMN_TITLE,
          COLUMN_BODY,
          COLUMN_CREATED,
          COLUMN_EDITED,
          COLUMN_COLOR
        ],
        orderBy: '$COLUMN_ID desc',
        where: '$COLUMN_TITLE LIKE ?',
        whereArgs: ['%$keywords%']);

    List<Note> noteList = [];

    for (var element in notes) {
      // deserialize each element
      Note n = Note.fromMap(element);
      noteList.add(n);
    }

    return noteList;
  }

  Future<Note> insert(Note note) async {
    final db = await database;
    note.id = await db.insert(TABLE_NOTE, note.toMap());
    return note;
  }

  Future<int> update(Note note) async {
    final db = await database;
    return await db.update(TABLE_NOTE, note.toMap(),
        where: 'id = ?', whereArgs: [note.id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      TABLE_NOTE,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
