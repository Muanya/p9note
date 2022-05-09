import 'package:flutter/material.dart';
import 'package:p9note/models/note.dart';

import '../main.dart';
import '../models/db_provider.dart';
import 'dialog_screen.dart';
import 'note_list_screen.dart';

class AllCategories extends StatefulWidget {
  const AllCategories({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _AllCategoriesState createState() => _AllCategoriesState();
}

class _AllCategoriesState extends State<AllCategories> {
  late List<NoteCategory> _noteCategoryList;
  late Color color;

  @override
  void initState() {
    super.initState();
    color = const Color(0xFFFFFFFF);

    // add a default category for all notes
    _noteCategoryList = [
      NoteCategory(
        id: -1,
        name: "All Notes",
        categoryColor: color,
      )
    ];
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
          body: Container(
            padding: const EdgeInsets.all(10.0),
            child: FutureBuilder(
              future: DatabaseProvider.db.getNoteCategory(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<NoteCategory>> snapshot) {
                if (snapshot.hasData) {
                  List<NoteCategory> notesCategory = snapshot.data!;
                  // if there are notes
                  if (notesCategory.isNotEmpty) {
                    return _noteCategoryScreen(notesCategory);
                  }

                  // if there are no notes in the database
                  return _defaultCategoryScreen();
                } else {
                  return _defaultCategoryScreen();
                }
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: NoteApp.baseColors['primary']!['base'],
            foregroundColor: NoteApp.baseColors['default']!['white'],
            child: const Icon(Icons.create_new_folder_sharp),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CreateCategoryDialogFragment(
                      color: color,
                    );
                  }).then((_) => setState(() {}));
            },
          ),
        ));
  }

  Widget _defaultCategoryScreen() {
    return ListView.builder(
        itemCount: _noteCategoryList.length,
        itemBuilder: (context, index) {
          return _listCategoryTile(context, _noteCategoryList, index);
        });
  }

  Widget _noteCategoryScreen(List<NoteCategory> noteCategoryList) {
    var finalCategoryList = _noteCategoryList + noteCategoryList;

    return ListView.builder(
        itemCount: finalCategoryList.length,
        itemBuilder: (context, index) {
          return _listCategoryTile(context, finalCategoryList, index);
        });
  }

  Widget _listCategoryTile(
      BuildContext context, List<NoteCategory> finalCategoryList, int index) {
    return GestureDetector(
      onTap: () => _navigateToNoteCategory(context, finalCategoryList[index]),
      onLongPress: () => _showCategoryDialog(finalCategoryList[index]),
      child: Container(
        width: 50.0,
        height: 120.0,
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Card(
          color: finalCategoryList[index].categoryColor,
          elevation: 10.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(finalCategoryList[index].name),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToNoteCategory(BuildContext context, NoteCategory nc) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NoteListPage(
                title: nc.name,
                id: nc.id,
              )),
    );
  }

  void _showCategoryDialog(NoteCategory nc) {
    var opt = [
      'delete',
    ];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0)
            ),
            child: SizedBox(
              height: 150,
              width: 70,
              child: ListView.builder(
                itemCount: opt.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _handleCategoryOption(CategoryOption.delete, nc),
                    child: ListTile(
                      title: Text(opt[index]),
                    ),
                  );
                },
              ),
            ),
          );
        }).then((_) => setState((){}));
  }

  _handleCategoryOption(CategoryOption opt, NoteCategory nc) {
    if(opt == CategoryOption.delete){
      var db = DatabaseProvider.db;
      db.deleteNoteCategory(nc.id);
      Navigator.pop(context);
    }
  }
}

enum CategoryOption {
  delete,
}
