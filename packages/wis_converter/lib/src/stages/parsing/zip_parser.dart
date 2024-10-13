import 'dart:io';

import 'package:wis_converter/src/stages/parsing/parser_base.dart';
import 'package:wis_converter/src/stages/splitting/split_result.dart';

import 'package:archive/archive_io.dart';

enum ZipType { none, document, image }

class ZipParser extends Parser {
  @override
  Future<void> parse(SplitResult result) async {
    /// Parse the given [SplitResult].
    final inputStream = InputFileStream(result.path);

    final archive = ZipDecoder().decodeBuffer(inputStream);

    final zipType = _getZipType(result.path);

    final dir = zipType == ZipType.document ? 'doc' : 'img';
    final path = result.outputPath.split('/');
    final last = path.removeLast();
    path.add(dir);
    path.add(last);

    final outputDir = Directory(path.join('/').replaceAll('.zip', ''));
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    for (final file in archive) {
      if (!file.isFile) continue;
      final outputFile = OutputFileStream('${outputDir.path}/${file.name}');
      file.writeContent(outputFile);
      outputFile.close();
    }
  }

  ZipType _getZipType(String filename) {
    filename = filename.split('/').last.replaceAll('.zip', '');
    if (filename.contains('images')) {
      return ZipType.image;
    } else {
      return ZipType.document;
    }
  }
}
