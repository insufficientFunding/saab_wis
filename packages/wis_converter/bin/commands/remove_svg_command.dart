import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path_util;
import 'package:wis_converter/src/util/print_util.dart';

class RemoveSvgCommand extends Command {
  @override
  // TODO: implement name
  String get name => 'remove-svg';
  @override
  String get description => 'Remove SVG commands from a directory.';

  @override
  FutureOr<void>? run() async {
    final input = argResults?.rest[0];
    if (input == null) {
      stderr.writeln('No input directory provided.');
      exit(2);
    }

    final validDir = Directory(path_util.canonicalize(input));
    if (!await validDir.exists()) {
      stderr.writeln('The input directory does not exist.');
      exit(2);
    }

    recursiveDeleteSvg(validDir);
  }

  Future<void> recursiveDeleteSvg(Directory directory) async {
    await for (final entity in directory.list()) {
      if (entity is File) {
        final filename = path_util.basename(entity.path);
        final extension = path_util.extension(filename);
        if (extension.toLowerCase() == '.svg') {
          await entity.delete();
          // Give me unicode bullet: •
          stdout.writeln(PrintUtil.color(' • Deleted $filename', PrintColor.blue));
        }
      } else if (entity is Directory) {
        await recursiveDeleteSvg(entity);
      }
    }
  }
}
