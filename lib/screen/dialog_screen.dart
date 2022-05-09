import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:p9note/models/utils.dart';

import '../models/db_provider.dart';
import '../models/note.dart';
import '../views/color_slider.dart';

class CreateCategoryDialogFragment extends StatefulWidget {
  final Color color;

  const CreateCategoryDialogFragment({
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  _CreateCategoryDialogFragmentState createState() => _CreateCategoryDialogFragmentState();
}

class _CreateCategoryDialogFragmentState extends State<CreateCategoryDialogFragment> {
  final _textController = TextEditingController();
  Color categoryColor = const Color(0xFFFFFFFF);

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Container(
        decoration: BoxDecoration(
            color: categoryColor, borderRadius: BorderRadius.circular(25.0)),
        padding: const EdgeInsets.only(bottom: 25.0, top: 15.0),
        child: Wrap(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(
                  top: 20.0, left: 8.0, right: 8.0, bottom: 10.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Category Name",
                  border: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.purple, width: 2.0),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                controller: _textController,
                maxLines: 1,
                cursorColor: Colors.blue,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (_textController.text != "") {
                      _makeCategory(_textController.text, categoryColor);
                    } else {
                      var msg = "Category name cannot be empty";
                      // create a toast showing the message
                      Fluttertoast.showToast(
                        msg: msg,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                      );
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Choose category color',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: SizedBox(
                height: 44,
                width: MediaQuery.of(context).size.width,
                child: ColorSlider(
                  callBackColorTapped: _onCategoryColorTapped,
                  noteColor: categoryColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _makeCategory(String text, Color color) {
    var errMsg = "Category already exist!";
    // check that the name is not the same as the default category
    if(text.toUpperCase() == Utils.DEFAULT_CATEGORY.toUpperCase()){
      // create a toast showing the message
      Fluttertoast.showToast(
        msg: errMsg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    var db = DatabaseProvider.db;
    db.getNoteCategory().then((value) {
      var existingNames = value.map((item) => item.name).toList();
      if (existingNames.contains(text)) {
        // create a toast showing the message
        Fluttertoast.showToast(
          msg: errMsg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      } else {
        NoteCategory nc = NoteCategory(
          id: -1,
          name: text,
          categoryColor: color,
        );
        db.insertNoteCategory(nc);
        Navigator.pop(context);
      }
    });
  }

  void _onCategoryColorTapped(Color p1) {
    categoryColor = p1;
    setState(() {});
  }
}
