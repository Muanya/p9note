import 'package:flutter/material.dart';

import 'color_slider.dart';

enum NoteOptions { delete, share, archive, removeFromCategory, addToCategory }

class MoreOptionSheet extends StatefulWidget {
  final Color color;
  final void Function(Color) colorChangedCallBack;
  final void Function(BuildContext, NoteOptions) noteOptionsCallBack;
  final int categoryId;

  const MoreOptionSheet({
    required this.color,
    required this.colorChangedCallBack,
    required this.noteOptionsCallBack,
    required this.categoryId,
    Key? key,
  }) : super(key: key);

  @override
  _MoreOptionSheetState createState() => _MoreOptionSheetState();
}

class _MoreOptionSheetState extends State<MoreOptionSheet> {
  late Color _noteColor;
  late int _categoryId;

  @override
  void initState() {
    super.initState();
    _noteColor = widget.color;
    _categoryId = widget.categoryId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _noteColor,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Wrap(
        children: <Widget>[
          // show this option only when in a category screen
          if(_categoryId != -1) Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () =>
                  widget.noteOptionsCallBack(context, NoteOptions.removeFromCategory),
              child: const ListTile(
                title: Text('Remove from this category'),
                trailing: Icon(Icons.remove),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () =>
                  widget.noteOptionsCallBack(context, NoteOptions.addToCategory),
              child: const ListTile(
                title: Text('Add to category'),
                trailing: Icon(Icons.add),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () =>
                  widget.noteOptionsCallBack(context, NoteOptions.share),
              child: const ListTile(
                title: Text('Share'),
                trailing: Icon(Icons.share),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () =>
                  widget.noteOptionsCallBack(context, NoteOptions.delete),
              child: const ListTile(
                title: Text('Delete'),
                trailing: Icon(Icons.delete),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () =>
                  widget.noteOptionsCallBack(context, NoteOptions.archive),
              child: const ListTile(
                title: Text('Archive'),
                trailing: Icon(Icons.archive),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: SizedBox(
              height: 44,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: ColorSlider(
                callBackColorTapped: _onColorTapped,
                noteColor: _noteColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onColorTapped(Color col) {
    setState(() {
      _noteColor = col;
      widget.colorChangedCallBack(col);
    });
  }
}
