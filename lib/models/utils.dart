import 'package:flutter/material.dart';
import 'package:p9note/models/note.dart';

import '../views/add_category_sheet.dart';
import '../views/more_options_sheet.dart';
import 'db_provider.dart';

class Utils {
  static const DEFAULT_CATEGORY = 'ALL NOTES';

  static void noteOptionsHandler(
      BuildContext context, NoteOptions opt, Note nt, bool isEditing) {
    if (opt == NoteOptions.share) {
      print("Share");
    } else if (opt == NoteOptions.delete) {
      // make sure the note is already in the database
      var noteDB = DatabaseProvider.db;
      noteDB
          .deleteNote(nt.id)
          .then((value) => print('Note $value has been deleted'));

      // if in editing mode, pop out the open note screen
      if (isEditing) Navigator.pop(context);
    } else if (opt == NoteOptions.removeFromCategory) {
      var noteDB = DatabaseProvider.db;
      noteDB.deleteJoint(nt.id, true);
    } else if (opt == NoteOptions.addToCategory) {

      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddCategorySheet(noteId: nt.id,);
          });
    } else {
      print('archive');
    }

    // pop the options sheet
    if (opt != NoteOptions.addToCategory) Navigator.pop(context);
  }
}
