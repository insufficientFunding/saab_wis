import 'package:wis_base/wis_base.dart';

class WisDtc extends WisDocument {
  final String code;
  final String description;

  final String diagnosticId, diagnosticStep, diagnosticEntry;

  WisDtc({
    required super.id,
    required this.code,
    required this.description,
    required this.diagnosticStep,
    required this.diagnosticEntry,
    required this.diagnosticId,
    required super.documentId,
  }) : super(
          name: code,
        );
}
