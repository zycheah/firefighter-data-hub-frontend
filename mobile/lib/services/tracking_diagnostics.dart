import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Appends timestamped tracking events to a log file in the app's documents
/// directory. The native iOS side appends to the same file.
class TrackingDiagnostics {
  static const String fileName = 'tracking_diagnostics.log';
  static const int _maxBytes = 512 * 1024;

  static File? _file;
  static Future<void> _pending = Future<void>.value();

  static void log(String event) {
    if (kIsWeb) return;
    final line = '${DateTime.now().toUtc().toIso8601String()} $event\n';
    _pending = _pending.then((_) => _append(line)).catchError((_) {});
  }

  static Future<void> _append(String line) async {
    var file = _file;
    if (file == null) {
      final dir = await getApplicationDocumentsDirectory();
      file = File(p.join(dir.path, fileName));
      _file = file;
    }

    // Keep the newest half once the file grows past the limit.
    if (await file.exists() && await file.length() > _maxBytes) {
      final content = await file.readAsString();
      final keepFrom = content.indexOf('\n', content.length ~/ 2) + 1;
      await file.writeAsString(content.substring(keepFrom));
    }

    await file.writeAsString(line, mode: FileMode.append, flush: true);
  }
}
