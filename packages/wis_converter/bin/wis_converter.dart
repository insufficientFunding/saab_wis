import 'dart:io';

import 'package:args/command_runner.dart';

import 'commands/split_command.dart';
import 'commands/organize_images_command.dart';
import 'commands/remove_svg_command.dart';

Future<void> main(List<String> arguments) async {
  exitCode = 0;

  final commandRunner = CommandRunner('wis_converter', 'Convert WIS files to a more usable format.')
    ..addCommand(SplitCommand())
    ..addCommand(OrganizeImagesCommand())
    ..addCommand(RemoveSvgCommand());

  await commandRunner.run(arguments).catchError((error) {
    stderr.writeln(error);
    exitCode = 2;
  });

  return;
}

class OrganizeImages {}
