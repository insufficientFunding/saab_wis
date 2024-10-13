import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:wis_converter/src/stages/organize_images/image_organizer.dart';
import 'package:wis_converter/src/util/path_util.dart';

import 'package:path/path.dart' as path_util;

class OrganizeImagesCommand extends Command {
  @override
  String get name => 'organize';
  @override
  String get description => 'Organize images into directories.';

  late final String _input;
  late final String _output;

  @override
  FutureOr<void>? run() async {
    await _initialize();

    stdout.writeln('Organizing images...');

    await ImageOrganizer(_input, _output).organize();

    stdout.writeln('Images organized.');
  }

  Future<void> _initialize() async {
    final results = argResults?.rest;
    final input = PathUtil.parse(results?[0]);
    _output = path_util.canonicalize(PathUtil.parse(results?[1])) + '/';

    if (await FileSystemEntity.isDirectory(input)) {
      _input = input;
    } else {
      throw 'The input directory does not exist.';
    }

    if (!await FileSystemEntity.isDirectory(_output)) {
      print(_output);
      await Directory(_output).create(recursive: true);
    }

    stdout.writeln('Organizing images from $_input...');
  }
}
