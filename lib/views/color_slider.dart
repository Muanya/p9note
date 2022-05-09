import 'package:flutter/material.dart';

class ColorSlider extends StatefulWidget {
  final void Function(Color) callBackColorTapped;
  final Color noteColor; // redefine this !!!

  const ColorSlider(
      {required this.callBackColorTapped, required this.noteColor, Key? key})
      : super(key: key);

  @override
  _ColorSliderState createState() => _ColorSliderState();
}

class _ColorSliderState extends State<ColorSlider> {
  int _selectedIndex = 0;
  final colors = const [
    Color(0xffffffff), // classic white
    Color(0xfff28b81), // light pink
    Color(0xfff7bd02), // yellow
    Color(0xfffbf476), // light yellow
    Color(0xffcdff90), // light green
    Color(0xffa7feeb), // turquoise
    Color(0xffcbf0f8), // light cyan
    Color(0xffafcbfa), // light blue
    Color(0xffd7aefc), // plum
    Color(0xfffbcfe9), // misty rose
    Color(0xffe6c9a9), // light brown
    Color(0xffe9eaee) // light gray
  ];

  final Color _borderColor = const Color(0xffd3d3d3);
  final Color _foregroundColor = const Color(0xff595959);

  final _checkWidget = const Icon(Icons.check);

  @override
  Widget build(BuildContext context) {
    return ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(colors.length, (index) {
          return GestureDetector(
            onTap: () => _colorTapped(index),
            child: Container(
              width: 58.0,
              height: 58.0,
              decoration: BoxDecoration(
                color: _borderColor,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                backgroundColor: colors[index],
                child: InkWell(
                  splashColor: _foregroundColor,
                  child: Material(
                    color: colors[index],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if(index == _selectedIndex) _checkWidget,

                      ],
                    ),
                  ),
                ),
              )
            ),
          );
        }));


    // return ListView(
    //     scrollDirection: Axis.horizontal,
    //     children: List.generate(colors.length, (index) {
    //       return GestureDetector(
    //         onTap: () => _colorTapped(index),
    //         child: Container(
    //           width: 58.0,
    //           height: 58.0,
    //           decoration: BoxDecoration(
    //             color: _borderColor,
    //             shape: BoxShape.circle,
    //           ),
    //           child: CircleAvatar(
    //             foregroundColor: _foregroundColor,
    //             backgroundColor: colors[index],
    //           ),
    //         ),
    //       );
    //     }));
  }

  void _colorTapped(int index) {
    _selectedIndex = index;
    var selectedColor = colors[index];
    widget.callBackColorTapped(selectedColor);
  }
}
