import 'dart:io';

import 'package:path/path.dart' as path_util;

abstract class Path {
  /// Canonicalize the given path, aditionally replacing tilde with the user's home directory.
  static String parsePath(String path) {
    path = path.replaceFirst('~', Platform.environment['HOME'].toString());
    path = path_util.canonicalize(path);

    return path;
  }

  /// Get the current working directory.
  static String get current => path_util.current;

  /// Get the system path separator.
  static String get separator => path_util.separator;

  /// Get the directory name of the given [path].
  /// This is everything before the last separator.
  static String dirname(String path) => path_util.dirname(path);

  /// Get the base name of the given [path].
  /// This is the last part of the path,
  /// and can be a file or directory name.
  static String basename(String path) => path_util.basename(path);

  /// Join the given [part1] and [part2] into a single path.
  static String join(String part1, String part2) => path_util.join(part1, part2);

  /// Get the extension of the given [path].
  /// This is everything after the last dot.
  /// If [level] is provided, it will allow for multiple extensions.
  ///```dart
  /// void main() {
  ///   print(Path.extension('path/to/file.tar.gz', 1)); // '.gz'
  ///   print(Path.extension('path/to/file.tar.gz', 2)); // '.tar.gz'
  ///}```
  static String extension(String path, [int level = 1]) => path_util.extension(path, level);

  /// Check if the given [path] is an absolute path.
  /// On POSIX systems, this means it starts with `/` (a forward slash).
  /// On Windows, an absolute path starts with `\\`,
  /// or a drive letter followed by `:/` or `:\`.
  static bool isAbsolute(String path) => path_util.isAbsolute(path);

  /// Check if the given [path] is a relative path.
  static bool isRelative(String path) => !isAbsolute(path);

  /// Attempts to convert the given [path] to a path relative
  /// to the current working directory, or the given [from] path.
  static String relative(String to, {String? from}) => path_util.relative(to, from: from);

  /// Normalize the given [path], removing any unnecessary separators.
  static String normalize(String path) => path_util.normalize(path);

  /// Split the given [path] into its components.
  /// This will return a list of each part of the path.
  static List<String> split(String path) => path_util.split(path);

  /// Get the root of the given [path].
  /// This is everything before the first separator.
  static String root(String path) => path_util.rootPrefix(path);
}
