import 'dart:async';
import 'package:flutter/material.dart';
import 'package:p9note/models/db_provider.dart';
import '../models/note.dart';
import '../views/more_options_sheet.dart';

class MakeNote extends StatefulWidget {
  final Note noteInEditing;

  const MakeNote({required this.noteInEditing, Key? key}) : super(key: key);

  @override
  _MakeNoteState createState() => _MakeNoteState();
}

class _MakeNoteState extends State<MakeNote> {
  /// A class for creating or editing the contents of the note
  ///
  late Note _editableNote;
  bool _isNewNote = false;
  final _titleFocus = FocusNode();
  final _bodyFocus = FocusNode();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  late Timer _persistenceTimer;

  // Hold initial values for undo
  late String _initialTitle;
  late String _initialBody;
  late DateTime _initialDateEdited;
  late Color _noteColor;

  @override
  void initState() {
    super.initState();
    _editableNote = widget.noteInEditing;
    _titleController.text = _editableNote.title;
    _bodyController.text = _editableNote.body;

    _initialDateEdited = _editableNote.dateLastEdited;
    _initialTitle = _editableNote.title;
    _initialBody = _editableNote.body;
    _noteColor = _editableNote.noteColor;

    if (_editableNote.id == -1) _isNewNote = true;

    _persistenceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // call insert query here
      // print("5 seconds passed");
      // print("editable note id: ${_editableNote.id}");
      _persistData();
    });
  }

  // dispose the various text controllers
  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (_isNewNote && _editableNote.title.isEmpty) {
    //   FocusScope.of(context).requestFocus(_titleFocus);
    // }

    return WillPopScope(
      onWillPop: _onExit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isNewNote ? 'New Note' : 'Edit Note'),
          elevation: 1,
          actions: _archiveActions(context),
        ),
        body: Container(
          color: _noteColor,
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
          ),
          child: SafeArea(
            left: true,
            right: true,
            top: false,
            bottom: false,
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(5.0),
                  child: TextField(
                    decoration: const InputDecoration(border: InputBorder.none),
                    controller: _titleController,
                    maxLines: 1,
                    focusNode: _titleFocus,
                    cursorColor: Colors.blue,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(0.0),
                      child: CustomPaint(
                        foregroundPainter: NotePainter(),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          expands: true,
                          controller: _bodyController,
                          focusNode: _bodyFocus,
                          cursorColor: Colors.black,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            height: 2.0,
                          ),
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  // for storing and updating the note
  void _persistData() {
    // update the Note object 
    _updateNoteObject();

    if (_editableNote.body.isNotEmpty || _editableNote.title.isNotEmpty) {
      var noteDB = DatabaseProvider.db;
      if (_isNewNote) {
        var note = noteDB.insert(_editableNote); // create a new note
        // update the id of the newly inserted note
        note.then((value) {
          _editableNote.id = value.id;
          _isNewNote = false;
        });
      } else {
        // for already existing note
        noteDB.update(_editableNote);
      }
    }
  }

  void _updateNoteObject() {
    _editableNote.title = _titleController.text;
    _editableNote.body = _bodyController.text;
    _editableNote.noteColor = _noteColor;

    if (!(_editableNote.body == _initialBody &&
        _editableNote.title == _initialTitle &&
        _editableNote.noteColor == _noteColor)) {
      // note is changed, so update the last edited date of the note
      _editableNote.dateLastEdited = DateTime.now();
    } else {
      // note is not changed but date last edited has changed
      // so update the last edited date of the note
      if (_editableNote.dateLastEdited != _initialDateEdited) {
        _editableNote.dateLastEdited = DateTime.now();
      }

    }
  }

  // method to call when the note is exited
  Future<bool> _onExit() async {
    _persistenceTimer.cancel();
    _persistData();
    return true;
  }

  void _bottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return MoreOptionSheet(
          color: _noteColor,
          colorChangedCallBack: _onColorChangedCallBack,
          noteOptionsCallBack: _noteOptionsHandler,
        );
      },
    );
  }

  List<Widget> _archiveActions(BuildContext context) {
    var actions = [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          child: GestureDetector(
            onTap: () => _bottomSheet(context),
            child: const Icon(
              Icons.more_vert,
            ),
          ),
        ),
      ),
    ];
    return actions;
  }

  void _onColorChangedCallBack(Color col) {
    setState(() {
      _noteColor = col;
    });
  }

  void _noteOptionsHandler(NoteOptions opt) {
    if (opt == NoteOptions.share) {
      print("Share");
    } else if (opt == NoteOptions.delete) {
      print('delete');
    } else {
      print('archive');
    }
  }
}

class NotePainter extends CustomPainter {
  /// Custom painter for the note editor
  ///
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 1.0;
    // for (var x = 0.0; x <= size.height; x += 32) {
    //   canvas.drawLine(Offset(0, x), Offset(size.width, x), paintLine);
    // }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // No need to repaint
    return false;
  }
}
