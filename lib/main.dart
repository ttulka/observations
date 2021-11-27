import 'package:flutter/material.dart';

import 'classroom_list.dart';

void main() {
  // MaterialColor berryColor = const MaterialColor(0xFF990F4B, {
  //   50: Color.fromRGBO(153, 15, 75, .1),
  //   100: Color.fromRGBO(153, 15, 75, .2),
  //   200: Color.fromRGBO(153, 15, 75, .3),
  //   300: Color.fromRGBO(153, 15, 75, .4),
  //   400: Color.fromRGBO(153, 15, 75, .5),
  //   500: Color.fromRGBO(153, 15, 75, .6),
  //   600: Color.fromRGBO(153, 15, 75, .7),
  //   700: Color.fromRGBO(153, 15, 75, .8),
  //   800: Color.fromRGBO(153, 15, 75, .9),
  //   900: Color.fromRGBO(153, 15, 75, 1),
  // });
  runApp(MaterialApp(
      title: 'Student Observations',
      home: const HomePage(),
      theme: ThemeData(
        primarySwatch: Colors.teal,
      )));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Student Observations'),
          leading: const IconButton(
            icon: Icon(Icons.menu),
            tooltip: 'Navigation menu',
            onPressed: null,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              tooltip: 'Exit',
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
        body: ClassroomList());
  }
}
