import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class Logger {
  static File? _logFile;

  static get _log async => _logFile ??= await _initLogFile();

  static Future<File> _initLogFile() async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/observations.log');
    if (file.existsSync()) {
      file.writeAsStringSync('Application started at ${DateTime.now()}\n');
    }
    return file;
  }

  static Future<void> debug(String message, [Object? e]) async {
    if (!kReleaseMode)
      await _logIt(stdout, _composeMessage('DEBUG', message, e));
  }

  static Future<void> info(String message, [Object? e]) =>
      _logIt(stdout, _composeMessage('INFO', message, e));

  static Future<void> error(String message, [Object? e]) =>
      _logIt(stderr, _composeMessage('ERROR', message, e));

  static String _composeMessage(String level, String message, Object? e) =>
      '${DateTime.now()} | $level: $message\n' +
      (e != null ? '${e.toString()}\n' : '');

  static Future<void> _logIt(Stdout out, String message) async {
    out.write(message);
    (await _log).writeAsStringSync(message, mode: FileMode.append);
  }
}
