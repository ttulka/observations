// ignore: todo
// TODO remove this hack when the feature is published.

import 'package:flutter/widgets.dart';
import 'package:observations/utils/widget_helpers.dart';
import 'persistence/database.dart' as db;
import 'persistence/storage.dart';

Future<void> execPreviewAction(BuildContext context, String cmd) async {
  switch (cmd) {
    case '#! r':
      await db.restore();
      break;
    case '#! p':
      await db.purge();
      break;
    case '#! a0':
      await db.updateProperty('autosave', '0');
      break;
    case '#! a1':
      await db.updateProperty('autosave', '1');
      break;
    case '#! h0':
      await db.updateProperty('headers', '0');
      break;
    case '#! h1':
      await db.updateProperty('headers', '1');
      break;
    case '#! c0':
      await db.updateProperty('printing_convert_html', '0');
      break;
    case '#! c1':
      await db.updateProperty('printing_convert_html', '1');
      break;
    case '#! i':
      final dbPath = (await db.DatabaseHolder.database).path;
      final storagePath = await FileStorage.directory;
      showAlert(context, 'Path to DB: $dbPath\n\nPath to files: $storagePath');
      break;
  }
}
