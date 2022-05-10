import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:p9note/models/db_provider.dart';
import 'package:p9note/models/note.dart';

class AddCategorySheet extends StatefulWidget {
  final int noteId;

  const AddCategorySheet({
    required this.noteId,
    Key? key,
  }) : super(key: key);

  @override
  _AddCategorySheetState createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  late List<NoteCategory> _markedCategory;

  @override
  void initState() {
    super.initState();
    _markedCategory = [];
  }

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
        ));
  }

  Widget _listCategory(List<NoteCategory> nc) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25.0)),
      padding: const EdgeInsets.only(bottom: 25.0, top: 15.0),
      child: Wrap(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Choose category",
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
              itemCount: nc.length,
              itemBuilder: (context, index) {
                //
                return ChooseCategory(
                  nc: nc[index],
                  isSelected: (value) => _categorySelected(value, nc[index]),
                );
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _addToSelectedCategory,
                  child: const Text('Ok'),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _noListCategory() {
    return const Center(
      child: Text('No Category Created!'),
    );
  }

  void _categorySelected(bool value, NoteCategory nc) {
    if (value) {
      _markedCategory.add(nc);
    } else {
      _markedCategory.remove(nc);
    }
  }

  void _addToSelectedCategory() {
    if (_markedCategory.isNotEmpty) {
      for (var element in _markedCategory) {
        // create a joint relationship
        var rel = Joint(noteID: widget.noteId, categoryID: element.id);
        // insert the relationship in the joint table
        DatabaseProvider.db.insertJointRel(rel);

      }
      Navigator.pop(context);
    }else{
      var msg = "No category selected";
      Fluttertoast.showToast(msg: msg);
    }
  }
}

class ChooseCategory extends StatefulWidget {
  final ValueChanged<bool> isSelected;
  final NoteCategory nc;

  const ChooseCategory({
    required this.isSelected,
    required this.nc,
    Key? key,
  }) : super(key: key);

  @override
  _ChooseCategoryState createState() => _ChooseCategoryState();
}

class _ChooseCategoryState extends State<ChooseCategory> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = false;
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.nc.name),
      value: _isSelected,
      onChanged: (bool? value) {
        setState(() {
          _isSelected = !_isSelected;
          widget.isSelected(_isSelected);
        });
      },
    );
  }
}
