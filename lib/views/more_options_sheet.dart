import 'package:flutter/material.dart';

import 'color_slider.dart';

enum NoteOptions { delete, share, archive }

class MoreOptionSheet extends StatefulWidget {
  final Color color;
  final void Function(Color) colorChangedCallBack;
  final void Function(NoteOptions) noteOptionsCallBack;

  const MoreOptionSheet({
    required this.color,
    required this.colorChangedCallBack,
    required this.noteOptionsCallBack,
    Key? key,
  }) : super(key: key);

  @override
  _MoreOptionSheetState createState() => _MoreOptionSheetState();
}

class _MoreOptionSheetState extends State<MoreOptionSheet> {
  late Color _noteColor;

  @override
  void initState() {
    super.initState();
    _noteColor = widget.color;
    print(_noteColor);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _noteColor,
      child: Wrap(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => widget.noteOptionsCallBack(NoteOptions.share),
              child: const ListTile(
                title: Text('Share'),
                trailing: Icon(Icons.share),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => widget.noteOptionsCallBack(NoteOptions.delete),
              child: const ListTile(
                title: Text('Delete'),
                trailing: Icon(Icons.delete),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => widget.noteOptionsCallBack(NoteOptions.archive),
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
              width: MediaQuery.of(context).size.width,
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
