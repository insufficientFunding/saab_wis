import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:wis_converter/src/enums/enums.dart';
import 'package:wis_converter/src/models/enums.dart';
import 'package:wis_converter/src/stages/splitting/split_result.dart';

class WisSplitter {
  final Directory input;
  final Directory output;
  final List<Model> models;
  final List<Language> languages;

  WisSplitter({
    required String input,
    required String output,
    required this.models,
    required this.languages,
  })  : input = Directory(input),
        output = Directory(output);

  Future<List<SplitResult>> split() async {
    final files = input.list();
    final results = <SplitResult>[];

    await for (final file in files) {
      if (file is Directory) {
        final filename = file.path.split('/').last;
        final model = models.firstWhereOrNull((model) => filename.contains(model.name));

        if (model == null) continue;

        final modelFiles = await _splitModel(file, model);
        results.addAll(modelFiles);
      }
    }

    return results;
  }

  Future<List<SplitResult>> _splitModel(Directory dir, Model current) async {
    final results = <SplitResult>[];
    final files = dir.list();
    stdout.writeln('Splitting ${current.name}, at ${dir.path}');

    await for (final file in files) {
      if (file is File) {
        final filename = file.path.split('/').last;
        final filetype = FileType.fromString(filename.split('.').last);
        if (filetype == FileType.none) continue;

        final model = current;

        var language = languages.firstWhereOrNull((language) =>
            language.isAtEndOfFile(filename) || language.isAtStartOfFile(filename.replaceAll(model.name, '')));
        if (language == null) {
          if (filename.contains('images')) {
            language = Language.english;
          } else {
            continue;
          }
        }

        final outputDirectory = Directory('${output.path}/${model.toString()}/${language.name}');
        if (!await outputDirectory.exists()) {
          await outputDirectory.create(recursive: true);
        }

        final newFileName = _getFileName(filename, model, language);

        // await file.copy('${outputDirectory.path}/$newFileName');

        StringBuffer sb = StringBuffer();
        sb.write(_addColor('   ', '34m'));
        sb.write(newFileName);
        sb.write(_getSpaces(newFileName));
        sb.write(_addColor('- ', '34m'));
        sb.write(language.name);

        stdout.writeln(sb.toString());

        results.add(SplitResult(
          model: model,
          path: file.path,
          outputPath: '${outputDirectory.path}/$newFileName',
          type: filetype,
          language: language,
        ));
      }
    }

    return results;
  }

  String _addColor(String text, String color) {
    return '\u001b[$color$text\u001b[0m';
  }

  String _getFileName(String fileName, Model model, Language language) {
    fileName = fileName.replaceAll(model.name, '');

    final split = fileName.split('.');
    fileName = split.first;

    final firstTwo = fileName.substring(0, 2);
    final lastTwo = fileName.substring(fileName.length - 2);

    if (firstTwo.toLowerCase() == language.code) {
      fileName = fileName.replaceRange(0, 2, '');
    } else if (lastTwo.toLowerCase() == language.code) {
      fileName = fileName.replaceRange(fileName.length - 2, fileName.length, '');
    }

    return '$fileName.${split.last}';
  }

  String _getSpaces(String fileName) {
    final spaces = 20 - min(20, fileName.length).toInt();
    return ' ' * spaces;
  }
}
