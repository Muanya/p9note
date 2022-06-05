import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:p9note/main.dart';
import 'package:p9note/models/db_provider.dart';
import 'package:p9note/models/utils.dart';
import 'package:p9note/views/more_options_sheet.dart';
import '../models/note.dart';
import 'dialog_screen.dart';
import 'make_note_screen.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({
    Key? key,
    required this.title,
    required this.id,
  }) : super(key: key);

  final String title;
  final int id;

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  late bool isHome;
  late bool _isInMarkedMode;
  late int _categoryID;
  late List<Note> _allNotes;
  late List<Note> _markedNotes;
  final ValueNotifier<int> _markedNotesNo = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    isHome = widget.id == -1 ? true : false;
    _isInMarkedMode = false;
    _categoryID = widget.id;
    _allNotes = [];
    _markedNotes = [];
  }

  @override
  Widget build(BuildContext context) {
    var primaryCol = NoteApp.baseColors['neutral']!['light'];

    return WillPopScope(
      onWillPop: () => _onBackButtonPressed(context),
      child: Theme(
        data: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
                primarySwatch: NoteApp.createMaterialColor(primaryCol!))),
        child: _displayNoteList(primaryCol),
      ),
    );
  }

  Future<List<Note>> buildNotes(int categoryId) async {
    if (isHome) return DatabaseProvider.db.getNotes();

    var joinList = await DatabaseProvider.db.queryJointTable(categoryId, false);
    var idList = <int>[];

    for (var element in joinList) {
      idList.add(element.noteID);
    }
    return DatabaseProvider.db.getNotesbyID(idList);
  }

  void _navigateToNote(BuildContext context, Note? note) {
    Note nt;
    if (note == null) {
      nt =
          Note(id: -1, dateLastEdited: DateTime.now(), noteColor: Colors.white);
    } else {
      nt = note;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MakeNote(
                  noteInEditing: nt,
                  categoryID: _categoryID,
                ))).then((value) => setState(() {}));
  }

  Widget _noNoteScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('images/home_pic.png'),
          const Text("Nothing here!")
        ],
      ),
    );
  }

  Widget _noteScreen(List<Note> noteList) {
    return ListView.builder(
        itemCount: noteList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _navigateToNote(context, noteList[index]),
            onLongPress: () => _showNoteDialog(noteList[index]),
            child: Container(
              width: 50.0,
              height: 120.0,
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Card(
                color: noteList[index].noteColor,
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: ListTile(
                  title: Text(noteList[index].title),
                  subtitle: Text(noteList[index]
                      .body
                      .substring(0, min(100, noteList[index].body.length))),
                ),
              ),
            ),
          );
        });
  }

  List<Widget> _moreActions(BuildContext context, Color color) {
    var listWidget = <Widget>[];

    listWidget += [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          child: GestureDetector(
            onTap: () => _bottomSheet(context, color),
            child: const Icon(
              Icons.more_vert,
            ),
          ),
        ),
      ),
    ];

    return listWidget;
  }

  void _bottomSheet(BuildContext context, Color color) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return HomeOptions(
          color: color,
        );
      },
    ).then((_) {
      setState(() {
        _isInMarkedMode = Utils.NOTE_MARKED;
        if (_isInMarkedMode) {
          // clear the marked note list
          _markedNotes.clear();
          // update the value listener
          _markedNotesNo.value = _markedNotes.length;
        }
      });
    });
  }

  void _showNoteDialog(Note nt) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            child: SizedBox(
              child: MoreOptionSheet(
                color: nt.noteColor,
                colorChangedCallBack: (col) => _colorChangedCallBack(col, nt),
                noteOptionsCallBack: (context, noteOptions) =>
                    Utils.noteOptionsHandler(context, noteOptions, nt, false),
                categoryId: _categoryID,
              ),
            ),
          );
        }).then((_) => setState(() {}));
  }

  void _colorChangedCallBack(Color col, Note nt) {
    var noteDB = DatabaseProvider.db;
    nt.noteColor = col;
    noteDB.updateNote(nt);
  }

  Widget _displayNoteList(Color primaryColor) {
    if (_isInMarkedMode) {
      return Scaffold(
        appBar: AppBar(
          title: ValueListenableBuilder(
            valueListenable: _markedNotesNo,
            builder: (BuildContext context, value, Widget? child) {
              return Text('$value selected');
            },
          ),
        ),
        body: _markedModeScreen(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: _moreActions(context, primaryColor),
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: FutureBuilder(
            future: buildNotes(_categoryID),
            builder:
                (BuildContext context, AsyncSnapshot<List<Note>> snapshot) {
              if (snapshot.hasData) {
                _allNotes = snapshot.data!;
                // if there are notes
                if (_allNotes.isNotEmpty) return _noteScreen(_allNotes);

                // if there are no notes in the database
                return _noNoteScreen();
              } else {
                return _noNoteScreen();
              }
            },
          ),
        ),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 10, left: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                backgroundColor: NoteApp.baseColors['primary']!['base'],
                foregroundColor: NoteApp.baseColors['default']!['white'],
                child: const Icon(Icons.add),
                onPressed: () => _navigateToNote(context, null),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _markedModeScreen() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _allNotes.length,
            itemBuilder: (context, index) {
              return Container(
                width: 50.0,
                height: 120.0,
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Card(
                  color: _allNotes[index].noteColor,
                  elevation: 10.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: NoteCheckboxList(
                    note: _allNotes[index],
                    isSelected: (value) {
                      if (value) {
                        // compile the notes selected
                        _markedNotes.add(_allNotes[index]);
                      } else {
                        // remove non selected notes
                        _markedNotes.remove(_allNotes[index]);
                      }

                      // update the valueListener
                      _markedNotesNo.value = _markedNotes.length;
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                padding: const EdgeInsets.all(10.0),
                child: const Icon(Icons.delete),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                padding: const EdgeInsets.all(10.0),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> _onBackButtonPressed(BuildContext context) {
    if (_isInMarkedMode) {
      setState(() {
        _isInMarkedMode = false;
        Utils.NOTE_MARKED = _isInMarkedMode;
      });
      return Future.value(false);
    } else {
      Navigator.of(context).pop(true);
      return Future.value(true);
    }
  }
}

class HomeOptions extends StatelessWidget {
  final Color color;

  const HomeOptions({required this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Wrap(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                // set flag for marked mode
                Utils.NOTE_MARKED = true;
                Navigator.pop(context);
              },
              child: const ListTile(
                title: Text('Mark'),
                trailing:
                    Icon(Icons.mark_chat_read_sharp), // TODO update the icon
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CreateCategoryDialogFragment(
                        color: color,
                      );
                    }).then((_) => Navigator.pop(context));
              },
              child: const ListTile(
                title: Text('Create new category'),
                trailing: Icon(Icons.create_new_folder),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NoteCheckboxList extends StatefulWidget {
  final ValueChanged isSelected;
  final Note note;

  const NoteCheckboxList({
    Key? key,
    required this.isSelected,
    required this.note,
  }) : super(key: key);

  @override
  _NoteCheckboxListState createState() => _NoteCheckboxListState();
}

class _NoteCheckboxListState extends State<NoteCheckboxList> {
  late bool _isSel;
  late Note _nt;

  @override
  void initState() {
    super.initState();
    _isSel = false;
    _nt = widget.note;
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: _isSel,
      onChanged: (value) {
        setState(() {
          _isSel = !_isSel;
          widget.isSelected(_isSel);
        });
      },
      title: Text(_nt.title),
      subtitle: Text(_nt.body.substring(0, min(100, _nt.body.length))),
    );
  }
}
