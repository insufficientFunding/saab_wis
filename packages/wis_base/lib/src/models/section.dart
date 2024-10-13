import 'package:wis_base/wis_base.dart';

class WisSection {
  final String id;
  final String name;
  final String number;

  final List<WisSection> subsections;
  final List<WisDocumentSection>? documentSections;

  WisSection({
    required this.id,
    required this.name,
    required this.number,
    List<WisSection>? subsections,
    this.documentSections,
  }) : subsections = subsections ?? [];
}
