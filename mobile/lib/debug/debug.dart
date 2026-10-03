import 'package:flutter/foundation.dart'; // Import debugPrint

class Log {
  // static const String _closeColor = "\x1B[0m";
  // static const String _red = "\x1B[31m";
  // static const String _green = "\x1B[32m";
  // static const String _yellow = "\x1B[33m";
  // static const String _blue = "\x1B[34m";

 

  static void success(String message) {
    debugPrint('\nSUCCESS: $message');
  }

  static void error(String data) {
    debugPrint('\nERROR: $data');
  }

  static void warning(String data) {
    debugPrint('\nWARNING: $data');
  }

  static void info(String data) {
    debugPrint('\nINFO: $data');
  }
}
