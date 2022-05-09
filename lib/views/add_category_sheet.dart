import 'package:flutter/material.dart';
import 'package:p9note/models/db_provider.dart';
import 'package:p9note/models/note.dart';

class AddCategorySheet extends StatefulWidget {
  const AddCategorySheet({Key? key}) : super(key: key);

  @override
  _AddCategorySheetState createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {


  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: FutureBuilder(
          future: DatabaseProvider.db.getNoteCategory(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              List<NoteCategory> nc = snapshot.data!;
              // if there are notes
              if (nc.isNotEmpty) return _listCategory(nc);

              // if there are no notes in the database
              return _noListCategory();
            } else {
              return _noListCategory();
            }
          },

        )
    );
  }

  Widget _listCategory(List<NoteCategory> nc) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
      ),
      padding: const EdgeInsets.only(bottom: 25.0, top: 15.0),
      child: ListView.builder(
        itemCount: nc.length,
          itemBuilder: (context, index) {
        //
        return ListTile(
          title: Text(nc[index].name),
        );
      }),
    );
  }

  Widget _noListCategory() {
    return const Center(
      child: Text('No Category Created!'),
    );
  }
}
