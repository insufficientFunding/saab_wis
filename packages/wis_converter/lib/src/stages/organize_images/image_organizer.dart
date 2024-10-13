import 'dart:io';

import 'package:path/path.dart' as path_util;
import 'package:wis_converter/src/util/print_util.dart';

class ImageOrganizer {
  final String _path;
  late final String _outputPath;

  ImageOrganizer(this._path, this._outputPath);

  static const List<String> _specialPrefixes = [
    'img',
  ];

  final Map<String, Directory> _directories = {};

  Future<void> organize() async {
    final directory = Directory(_path);

    await for (final entity in directory.list()) {
      if (entity is Directory) continue;
      if (entity is File) {
        final filename = path_util.basenameWithoutExtension(entity.path).toUpperCase();
        final extension = path_util.extension(entity.path);
        if (_specialPrefixes.any((prefix) => filename.startsWith(prefix.toUpperCase()))) {
          final prefix = _specialPrefixes.firstWhere((prefix) => filename.toLowerCase().startsWith(prefix));
          if (!_directories.containsKey(prefix)) {
            _directories[prefix] = await Directory('$_outputPath/${prefix.toUpperCase()}').create(recursive: true);
          }

          await entity.rename('${_directories[prefix]!.path}/${filename.toUpperCase()}$extension');
        } else {
          final firstTwoCharacters = filename.substring(0, 2).toUpperCase();
          if (!_directories.containsKey(firstTwoCharacters)) {
            _directories[firstTwoCharacters] =
                await Directory('$_outputPath/$firstTwoCharacters').create(recursive: true);
          }

          await entity.rename('${_directories[firstTwoCharacters]!.path}/${filename.toUpperCase()}$extension');
        }
        stdout.writeln(PrintUtil.color(' • $filename', PrintColor.green));
      }
    }
  }
}
