import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:wis_converter/src/enums/enums.dart';
import 'package:wis_converter/src/stages/parsing/parser.dart';
import 'package:wis_converter/src/util/path_util.dart';
import 'package:wis_converter/wis_converter.dart';

class SplitCommand extends Command {
  @override
  final name = 'split';
  @override
  final description = 'Split a directory of WIS files into individual files.';

  late final String _input;
  late final String _output;

  List<Model> _models = [Model.none];
  List<Model> get models => _models;

  List<Language> _languages = [Language.none];
  List<Language> get languages => _languages;

  SplitCommand() {
    argParser.addMultiOption(
      'models',
      abbr: 'm',
      help: 'The models to include.',
      allowed: ['9_3ng'],
      defaultsTo: ['9_3ng'],
    );

    argParser.addMultiOption(
      'languages',
      abbr: 'l',
      help: 'The languages to include.',
      allowed: ['en', 'es'],
      defaultsTo: ['gb'],
    );
  }

  @override
  Future<void>? run() async {
    await _initialize();

    stdout.writeln('Loading models...');
    await _findModels();

    stdout.writeln('Loading languages...');
    await _findLanguages();

    stdout.writeln('Splitting files...');
    final splitter = WisSplitter(
      input: _input,
      output: _output,
      models: _models,
      languages: _languages,
    );

    final result = await splitter.split();
    stdout.writeln('Files have been split.');

    stdout.writeln('Parsing files...');
    final parser = ParserStage(
      results: result,
    );

    await parser.parse();
    stdout.writeln('Files have been parsed.');

    await Future.delayed(Duration(seconds: 1));
    stdout.writeln('Conversion complete.');
  }

  Future<void> _initialize() async {
    final results = argResults?.rest;
    final input = PathUtil.parse(results?[0]);
    final output = PathUtil.parse(results?[1]);

    if (FileSystemEntity.isDirectorySync(input)) {
      _input = input;
    } else {
      throw 'The input directory does not exist.';
    }

    if (FileSystemEntity.isDirectorySync(output)) {
      _output = output;
    } else {
      _output = (await Directory(output).create()).path;
    }

    stdout.writeln('Splitting files from $_input to $_output...');
  }

  Future<void> _findModels() async {
    final models = argResults?['models'] as List<String>;

    for (final model in models) {
      _models.add(Model.fromString(model));
      stdout.writeln('Model: ${Model.fromString(model).name}');
    }
  }

  Future<void> _findLanguages() async {
    final languages = argResults?['languages'] as List<String>;

    for (final language in languages) {
      _languages.add(Language.fromString(language));
      stdout.writeln('Language: ${Language.fromString(language).name}');
    }
  }
}
