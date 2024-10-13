import 'dart:io';

import 'package:path/path.dart' as path_util;

abstract class PathUtil {
  static String parse(String? path) {
    if (path == null || path.trim().isEmpty) {
      throw 'The path is null or empty.';
    }

    // If we find a tilde, we need to expand it to the user's home directory.
    if (path.startsWith('~')) {
      path = getHome() + path.substring(1);
    }

    // If the path is not absolute, we need to make it absolute.
    if (!path.startsWith('/')) {
      path = Directory.current.path + '/' + path;
    }

    return path_util.normalize(path);
  }

  static String getHome() {
    String home = '';

    Map<String, String> envVars = Platform.environment;
    if (Platform.isWindows) {
      home = envVars['UserProfile']!;
    } else {
      home = envVars['HOME']!;
    }

    return home;
  }
}
