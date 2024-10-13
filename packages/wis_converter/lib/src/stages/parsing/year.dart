import 'dart:io';

import 'package:wis_converter/src/stages/parsing/parser_base.dart';
import 'package:wis_converter/src/stages/splitting/split_result.dart';

import 'package:path/path.dart' as path_util;

class YearParser extends Parser {
  @override
  Future<void> parse(SplitResult result) async {
    final filename = path_util.basenameWithoutExtension(result.path);
    final extension = path_util.extension(result.path);

    final year = filename.substring(0, 4);
    final newFilename = filename.replaceFirst(year, '');

    final newFile = File('${result.outputPath}/$year/$newFilename$extension');
    await newFile.create(recursive: true);
  }
}
