import 'package:flutter/material.dart';
import 'package:p9note/main.dart';
import 'package:p9note/models/db_provider.dart';

import '../models/note.dart';
import 'make_note_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var primaryCol = NoteApp.baseColors['neutral']!['light'];

    return Theme(
        data: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
                primarySwatch: NoteApp.createMaterialColor(primaryCol!))),
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: FutureBuilder(
            future: DatabaseProvider.db.getNotes(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Note>> snapshot) {
              if (snapshot.hasData) {
                List<Note> notes = snapshot.data!;
                // if there are notes
                if (notes.isNotEmpty) return _noteScreen(notes);

                // if there are no notes in the database
                return _noNoteScreen();
              } else {
                return _noNoteScreen();
              }
            },
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
                  onPressed: () => _makeNewNote(context),
                ),
              ],
            ),
          ),
        ));
  }

  void _makeNewNote(BuildContext context) {
    Note nt =
        Note(id: -1, dateLastEdited: DateTime.now(), noteColor: Colors.white);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MakeNote(
                  noteInEditing: nt,
                )));
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
          return Container(
            child: Column(
              children: <Widget>[
                Text(noteList[index].title),
                Text(noteList[index].body.substring(0, 10)),
              ],
            ),
          );
        });
  }
}
