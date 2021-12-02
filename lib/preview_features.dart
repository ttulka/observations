// TODO remove this hack when the feature is published.

import 'package:flutter/widgets.dart';
import '../persistence/database.dart' as db;

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
  }
}
