import 'dart:io';

import 'package:wis_base/wis_base.dart';
import 'package:wis_navigation/wis_navigation.dart';
import 'package:xml/xml.dart';

class WisEcmParser extends XmlParser<List<WisEcm>> {
  late List<WisEcm> _ecms;

  @override
  Future<List<WisEcm>> parse(String path) async {
    final file = File(path);
    if (!await file.exists()) throw 'The file $file does not exist.';

    final fileContent = await file.readAsString();
    final document = XmlDocument.parse(fileContent);
    final root = document.rootElement;
    final ecmElements = root.findElements('ecm');

    _ecms = <WisEcm>[];

    for (final ecmElement in ecmElements) {
      await _parseEcm(ecmElement);
    }

    return _ecms;
  }

  Future<void> _parseEcm(XmlElement ecmElement) async {
    final id = ecmElement.getAttribute('id');
    final name = ecmElement.getAttribute('name');
    final dtcElements = ecmElement.findElements('dtc');

    if (id == null || name == null) {
      throw 'The ECM must have an id and name. Values: id=$id, name=$name';
    }

    final dtcs = <WisDtc>[];
    for (final dtcElement in dtcElements) {
      final dtc = await _parseDtc(dtcElement);
      dtcs.add(dtc);
    }

    final ecm = WisEcm(id: id, name: name, dtcs: dtcs);
    _ecms.add(ecm);
  }

  Future<WisDtc> _parseDtc(XmlElement dtcElement) async {
    final id = dtcElement.getAttribute('id');
    final code = dtcElement.getElement('fcode')?.innerText;

    if (id == null || code == null) {
      throw 'The DTC must have an id and code. Values: id=$id, code=$code';
    }

    final cmElement = dtcElement.getElement('cm');
    if (cmElement == null) throw 'The DTC must have a cm element.';

    final diagnosticId = cmElement.getAttribute('id');
    final documentId = cmElement.getAttribute('docid');

    final diagnosticElement = cmElement.getElement('diagnostic');
    if (diagnosticElement == null) throw 'The CM must have a diagnostic element.';

    final diagnosticStep = diagnosticElement.getAttribute('step');
    final diagnosticEntry = diagnosticElement.getAttribute('entry');

    final descriptionElement = diagnosticElement.getElement('sympdesc');
    if (descriptionElement == null) throw 'The diagnostic must have a sympdesc element.';

    final description = descriptionElement.innerText;

    if (diagnosticId == null || documentId == null || diagnosticStep == null || diagnosticEntry == null) {
      throw 'The CM must have an id, docid, step, and entry. Values: id=$diagnosticId, docid=$documentId, step=$diagnosticStep, entry=$diagnosticEntry';
    }

    return WisDtc(
      id: id,
      code: code,
      description: description,
      diagnosticId: diagnosticId,
      documentId: documentId,
      diagnosticStep: diagnosticStep,
      diagnosticEntry: diagnosticEntry,
    );
  }
}
