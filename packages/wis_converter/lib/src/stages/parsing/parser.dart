import 'dart:io';
import 'dart:isolate';

import 'package:wis_converter/src/enums/enums.dart';
import 'package:wis_converter/src/models/enums.dart';
import 'package:wis_converter/src/stages/parsing/parser_base.dart';
import 'package:wis_converter/src/stages/parsing/zip_parser.dart';
import 'package:wis_converter/src/stages/splitting/split_result.dart';

import 'package:path/path.dart' as path_util;
import 'package:wis_converter/src/util/print_util.dart';

Parser? _getParser({FileType? type, String? filename, required Model model}) {
  switch (type) {
    case FileType.zip:
      return ZipParser();
    default:
  }

  return null;
}

class ParserStage {
  final List<SplitResult> _results;

  ParserStage({required List<SplitResult> results}) : _results = results;

  Future<void> parse() async {
    for (final result in _results) {
      final parser = _getParser(type: result.type, filename: path_util.basename(result.path), model: result.model);
      if (parser == null) {
        stdout.writeln(PrintUtil.color(
            '   no parser found for ${path_util.basename(result.path)} (${result.type.name})', PrintColor.yellow));
        // We just copy the file over if we don't have a parser.
        final file = File(result.path);
        await file.copy(result.outputPath);
        continue;
      }

      Isolate.run(() async => await parser.parse(result));
    }
  }
}
