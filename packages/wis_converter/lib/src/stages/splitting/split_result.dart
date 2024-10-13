import 'package:wis_converter/src/enums/enums.dart';
import 'package:wis_converter/src/models/enums.dart';

class SplitResult {
  final String path;
  final FileType type;
  final Language language;
  final Model model;
  final String outputPath;

  SplitResult({
    required this.path,
    required this.type,
    required this.language,
    required this.model,
    required this.outputPath,
  });
}
