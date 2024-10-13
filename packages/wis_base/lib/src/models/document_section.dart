import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wis_base/wis_base.dart';

enum WisDocumentSectionType {
  technicalData('Technical data', icon: FontAwesomeIcons.clipboardList),
  technicalDescription('Technical description', icon: Icons.library_books),
  specialTools('Special tools', icon: FontAwesomeIcons.screwdriverWrench),
  wiringDiagram('Wiring diagram', icon: FontAwesomeIcons.compassDrafting),
  bulletins('Bulletins - SI/MI', icon: FontAwesomeIcons.bullhorn),
  generalFaultDiagnosis('Fault diagnosis, general', icon: FontAwesomeIcons.kitMedical),
  faultSymptoms('Fault diagnosis, fault symptoms', icon: FontAwesomeIcons.thermometer),
  adjustmentOrReplacement('Adjustment/replacement', icon: FontAwesomeIcons.wrench),
  service('Service', icon: FontAwesomeIcons.oilCan),
  locationOfComponents('Location of components', icon: FontAwesomeIcons.upDownLeftRight);

  final String name;
  final IconData icon;

  const WisDocumentSectionType(this.name, {this.icon = Icons.folder});

  factory WisDocumentSectionType.fromString(String value) {
    return WisDocumentSectionType.values
        .firstWhere((e) => e.name == value, orElse: () => throw Exception('WisDocumentSectionType not found $value'));
  }
}

class WisDocumentSection {
  final String id;
  final String number;
  final WisDocumentSectionType type;
  final List<WisDocument> documents;

  WisDocumentSection({
    required this.id,
    required this.number,
    required this.type,
    required this.documents,
  });
}
