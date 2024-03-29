import 'package:flutter/material.dart';

import '../main.dart';
import 'all_categories_screen.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('images/welcome_pic.png'),
            Container(
              width: 311.0,
              height: 40.0,
              margin: const EdgeInsets.symmetric(vertical: 70.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: NoteApp.baseColors['default']!['black'],
                  backgroundColor: NoteApp.baseColors['default']!['background'],
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AllCategories(
                              title: "Note Categories",
                            )),
                  );
                },
                child: const Text('Go to notes'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
