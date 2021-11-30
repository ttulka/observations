import 'package:flutter/material.dart';
import 'dart:io';
import 'package:window_size/window_size.dart';
import 'classroom_list.dart';
import 'category_list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      const width = 1024.0;
      const height = 800.0;
      setWindowTitle("Student Observations");
      setWindowMinSize(const Size(width, height));
      setWindowFrame(const Rect.fromLTWH(50, 50, width, height));
    }
  } catch (e) {
    // ignore: avoid_print
    print('Cannot determine platform: $e');
  }
  runApp(const ObservationsApp());
}

const color = Colors.blue;

class ObservationsApp extends StatelessWidget {
  const ObservationsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Student Observations',
        home: HomePage(),
        theme: ThemeData(
          primarySwatch: color,
        ));
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Student Observations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            tooltip: 'About',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
      body: ClassroomList(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: color,
              ),
              child: Icon(Icons.settings, size: 48),
            ),
            ListTile(
              title: const Text('Categories'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryList(),
                  ),
                );
                final state = _scaffoldKey.currentState;
                if (state != null && state.isDrawerOpen) {
                  state.openEndDrawer();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
