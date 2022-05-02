import 'package:flutter/material.dart';
import 'package:p9note/screen/welcome_screen.dart';

void main() {
  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({Key? key}) : super(key: key);

  static const Map<String, ColorSwatch> baseColors = <String, ColorSwatch> {
    'default': ColorSwatch(0xFFFAF8FC, {
      'background': Color(0xFFFAF8FC),
      'black': Color(0xFF180E25),
      'white': Color(0xFFFFFFFF)
    }),
    'primary': ColorSwatch(0xFF6A3EA1, {
      'base': Color(0xFF6A3EA1),
      'dark': Color(0xFF3A2258),
      'light': Color(0xFFEFE9F7),
      'background': Color(0xFFFAF8FC)
    }),
    'secondary': ColorSwatch(0xFFDEDC52, {
      'base': Color(0xFFDEDC52),
      'dark': Color(0xFF565510),
      'light': Color(0xFFF7F6D4),
    }),
    'neutral': ColorSwatch(0xFFC8C5CB, {
      'base': Color(0xFFC8C5CB),
      'dark': Color(0xFF827D89),
      'light': Color(0xFFEFEEF0),
    }),
    'success': ColorSwatch(0xFF60D889, {
      'base': Color(0xFF60D889),
      'dark': Color(0xFF1F7F40),
      'light': Color(0xFFDAF6E4),
    }),
    'error': ColorSwatch(0xFFCE3A54, {
      'base': Color(0xFFCE3A54),
      'dark': Color(0xFF5A1623),
      'light': Color(0xFFF7DEE3),
    }),
    'warning': ColorSwatch(0xFFF8C715, {
      'base': Color(0xFFF8C715),
      'dark': Color(0xFF725A03),
      'light': Color(0xFFFDEBAB),
    }),
  };

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes',
      theme: customTheme(),
      home: const WelcomePage(title: 'Notes'),
    );
  }

  ThemeData customTheme() {
    Color? primaryCol = baseColors['primary']!['base'];
    Color? secondaryCol = baseColors['secondary']!['base'];

    return ThemeData(
      // brightness: Brightness.dark,
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: primaryCol,
      textTheme: const TextTheme(
        headline1: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
        headline6: TextStyle(fontSize: 30.0, fontStyle: FontStyle.italic),
        bodyText2: TextStyle(fontSize: 18.0, fontFamily: 'Hind'),
      ),
      colorScheme: ColorScheme.fromSwatch(
              primarySwatch: createMaterialColor(primaryCol!))
          .copyWith(secondary: secondaryCol),
    );
  }

  // creates a material color using given custom color
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }
}
