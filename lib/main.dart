import 'package:flutter/material.dart';

import 'classroom_list.dart';

void main() {
  runApp(MaterialApp(
      title: 'Student Observations',
      home: const HomePage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
            icon: Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: null,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help),
              tooltip: 'About',
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
        body: ClassroomList());
  }
}
