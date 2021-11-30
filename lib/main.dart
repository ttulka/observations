import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:window_size/window_size.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database.dart';
import 'classroom_list.dart';
import 'category_list.dart';

const appTitle = 'Student Observations';
const color = Colors.blue;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      const width = 1024.0;
      const height = 800.0;
      setWindowTitle(appTitle);
      setWindowMinSize(const Size(width, height));
      setWindowFrame(const Rect.fromLTWH(50, 50, width, height));
    }
  } catch (e) {
    // ignore: avoid_print
    print('Cannot determine platform: $e');
  }
  DatabaseHolder.connectDatabase();
  runApp(const ObservationsApp());
}

class ObservationsApp extends StatelessWidget {
  const ObservationsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      home: HomePage(),
      theme: ThemeData(
        primarySwatch: color,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('de', ''),
      ],
    );
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
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            tooltip: AppLocalizations.of(context)!.menuAbout,
            onPressed: () => Navigator.of(context).restorablePush(_aboutDialog),
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
              title: Text(AppLocalizations.of(context)!.menuCategories),
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

  static Route<Object?> _aboutDialog(BuildContext context, Object? arguments) {
    final link = AppLocalizations.of(context)!.aboutLink;
    return DialogRoute<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Center(child: Text(AppLocalizations.of(context)!.aboutTitle)),
        content: Column(
          children: [
            Center(
              child: InkWell(
                child: Text(
                  link,
                  style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
                onTap: () => launch(link),
              ),
            ),
            Center(child: Text('\n\n' + AppLocalizations.of(context)!.aboutContent, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
