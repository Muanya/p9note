import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'note.dart';

class DatabaseProvider {
  // table names in the database
  static const String TABLE_NOTE = 'note_table';
  static const String TABLE_CATEGORY = 'note_category_table';
  static const String TABLE_JOINT = 'joint_table';

  // column names in the note table
  static const String COLUMN_ID = 'id';
  static const String COLUMN_NOTE_TITLE = 'title';
  static const String COLUMN_NOTE_BODY = 'body';
  static const String COLUMN_CREATED = 'date_created';
  static const String COLUMN_NOTE_EDITED = 'date_last_edited';
  static const String COLUMN_NOTE_COLOR = 'note_color';

  // column names in the category table
  static const String COLUMN_CATEGORY_NAME = 'category_name';
  static const String COLUMN_CATEGORY_COLOR = 'note_color';

  // column names in the joint table
  static const String COLUMN_CATEGORY_ID = 'category_id';
  static const String COLUMN_NOTE_ID = 'note_id';

  // name of the database
  static const String DB_NAME = 'notesDb.db';

  DatabaseProvider._(); // private constructor

  static final db = DatabaseProvider._(); // singleton

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
      // create note table
      await db.execute(
        "CREATE TABLE $TABLE_NOTE ("
        "$COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$COLUMN_NOTE_TITLE BLOB,"
        "$COLUMN_NOTE_BODY BLOB, $COLUMN_CREATED INTEGER, $COLUMN_NOTE_EDITED INTEGER, $COLUMN_NOTE_COLOR INTEGER"
        ")",
      );

      // create category table
      await db.execute(
        "CREATE TABLE $TABLE_CATEGORY ("
        "$COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$COLUMN_CATEGORY_NAME TEXT,"
        "$COLUMN_CREATED INTEGER, $COLUMN_CATEGORY_COLOR INTEGER"
        ")",
      );

      // create the joint table
      await db.execute(
        "CREATE TABLE $TABLE_JOINT ("
        "$COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$COLUMN_CATEGORY_ID INTEGER,"
        "$COLUMN_NOTE_ID INTEGER"
        ")",
      );
    });
  }

  Future<List<Note>> getNotes() async {
    final db = await database;

    var notes = await db.query(TABLE_NOTE,
        columns: [
          COLUMN_ID,
          COLUMN_NOTE_TITLE,
          COLUMN_NOTE_BODY,
          COLUMN_CREATED,
          COLUMN_NOTE_EDITED,
          COLUMN_NOTE_COLOR
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

  Future<List<Note>> getNotesbyID(List<int> idList) async {
    final db = await database;

    List<Note> noteList = [];

    for (var id in idList) {
      var note = await db.query(TABLE_NOTE,
          columns: [
            COLUMN_ID,
            COLUMN_NOTE_TITLE,
            COLUMN_NOTE_BODY,
            COLUMN_CREATED,
            COLUMN_NOTE_EDITED,
            COLUMN_NOTE_COLOR
          ],
          orderBy: '$COLUMN_ID desc',
          where: '$COLUMN_ID = ?',
          whereArgs: [id]);

      Note n = Note.fromMap(note[0]);
      noteList.add(n);
    }

    return noteList;
  }

  Future<List<Note>> getNotesWithTitleKeywords(String keywords) async {
    final db = await database;

    var notes = await db.query(TABLE_NOTE,
        columns: [
          COLUMN_ID,
          COLUMN_NOTE_TITLE,
          COLUMN_NOTE_BODY,
          COLUMN_CREATED,
          COLUMN_NOTE_EDITED,
          COLUMN_NOTE_COLOR
        ],
        orderBy: '$COLUMN_ID desc',
        where: '$COLUMN_NOTE_TITLE LIKE ?',
        whereArgs: ['%$keywords%']);

    List<Note> noteList = [];

    for (var element in notes) {
      // deserialize each element
      Note n = Note.fromMap(element);
      noteList.add(n);
    }

    return noteList;
  }

  Future<Note> insertNote(Note note) async {
    final db = await database;
    note.id = await db.insert(TABLE_NOTE, note.toMap());
    return note;
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(TABLE_NOTE, note.toMap(),
        where: 'id = ?', whereArgs: [note.id]);
  }

  Future<int> deleteNote(int id) async {
    final db = await database;

    // delete all note instance in the joint relationship table
    deleteJoint(id, true);

    // delete the note
    return await db.delete(
      TABLE_NOTE,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// category query section

  Future<List<NoteCategory>> getNoteCategory() async {
    final db = await database;

    var notes = await db.query(TABLE_CATEGORY,
        columns: [
          COLUMN_ID,
          COLUMN_CATEGORY_NAME,
          COLUMN_CATEGORY_COLOR,
          COLUMN_CREATED,
        ],
        orderBy: '$COLUMN_ID desc');

    List<NoteCategory> noteCategoryList = [];

    for (var element in notes) {
      // deserialize each element
      NoteCategory n = NoteCategory.fromMap(element);
      noteCategoryList.add(n);
    }

    return noteCategoryList;
  }

  Future<NoteCategory> insertNoteCategory(NoteCategory noteCategory) async {
    final db = await database;
    noteCategory.id = await db.insert(TABLE_CATEGORY, noteCategory.toMap());
    return noteCategory;
  }

  Future<int> updateNoteCategory(NoteCategory noteCategory) async {
    final db = await database;
    return await db.update(TABLE_CATEGORY, noteCategory.toMap(),
        where: 'id = ?', whereArgs: [noteCategory.id]);
  }

  Future<int> deleteNoteCategory(int id) async {
    final db = await database;

    // delete all instance of the note category from the joint table
    deleteJoint(id, false);

    return await db.delete(
      TABLE_CATEGORY,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Joint table query section

  Future<Joint> insertJointRel(Joint rel) async {
    final db = await database;
    await db.insert(TABLE_JOINT, rel.toMap());
    return rel;
  }

  Future<List<Joint>> queryJointTable(int id, bool forNote) async {
    /// id is the index of the note or the note category
    /// to use in querying the joint table
    ///
    ///  forNote is set to true, if the id is for Note object
    ///  else it is set to false for NoteCategory object

    var searchKey = forNote ? COLUMN_NOTE_ID : COLUMN_CATEGORY_ID;
    final db = await database;
    List<Joint> rel = [];

    var n = await db.query(
      TABLE_JOINT,
      columns: [
        COLUMN_NOTE_ID,
        COLUMN_CATEGORY_ID,
      ],
      where: '$searchKey = ?',
      whereArgs: [id],
    );

    for (var element in n) {
      // deserialize each element
      Joint j = Joint.fromMap(element);
      rel.add(j);
    }

    return rel;
  }

  /// TODO: Implement delete of a category and delete of a note

  Future<int> deleteJoint(int id, bool forNote) async {
    /// forNote is set to true if @id is the id of Note object
    /// else it is set to false if @id is the id of NoteCategory object
    final db = await database;
    var searchKey = forNote ? COLUMN_NOTE_ID : COLUMN_CATEGORY_ID;

    return await db.delete(
      TABLE_JOINT,
      where: '$searchKey = ?',
      whereArgs: [id],
    );
  }
}
