import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:wis_base/wis_base.dart';
import 'package:wis_navigation/src/xml/parser/ecm_parser.dart';
import 'package:wis_navigation/src/xml/parser/parser.dart';
import 'package:xml/xml.dart';

class WisXmlParser extends XmlParser<void> {
  late WisModelData modelData;

  WisXmlParser();

  @override
  Future<WisModelData> parse(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw 'The file $file does not exist.';
    }

    final fileContent = await file.readAsString(encoding: utf8);

    final document = XmlDocument.parse(fileContent);
    final root = document.rootElement;

    await _parseRoot(root: root);

    final sections = await _parseSections(element: root);
    modelData.sections.addAll(sections);

    await _parseEcms(basePath: path);

    return modelData;
  }

  Future<void> _parseRoot({required XmlElement root}) async {
    final attributes = root.attributes;
    final modelString = attributes.firstWhereOrNull((attribute) => attribute.name.local == 'carmodel')?.value;
    final modelYear = attributes.firstWhereOrNull((attribute) => attribute.name.local == 'modelyear')?.value;
    final languageString = attributes.firstWhereOrNull((attribute) => attribute.name.local == 'language')?.value;

    if (modelString == null || modelYear == null || languageString == null) {
      throw 'The root element must have a carmodel, modelyear, and language attribute.';
    }

    modelData = WisModelData(
      model: Model.fromName(modelString),
      year: modelYear,
      language: Language.fromString(languageString),
    );
  }

  Future<List<WisSection>> _parseSections({required XmlElement element}) async {
    final sections = <WisSection>[];

    final elementName = switch (element.name.local) {
      'modelyear' => 'sct',
      'sct' => 'sc',
      'sc' => 'scsub',
      _ => 'sct',
    };

    final elements = element.findElements(elementName);

    for (final section in elements) {
      final id = section.getAttribute('id');
      final number = section.getAttribute('num');
      final name = section.getElement('name')?.innerText;

      if (id == null || number == null || name == null) {
        throw 'The section must have an id, number, and name. Values: id=$id, number=$number, name=$name';
      }

      final subsections = await _parseSections(element: section);

      final wisSection = WisSection(
        id: id,
        number: number,
        name: name,
        subsections: subsections,
        documentSections: subsections.isEmpty ? await _parseDocumentSections(element: section) : null,
      );

      sections.add(wisSection);
    }

    return sections;
  }

  Future<List<WisDocumentSection>?> _parseDocumentSections({required XmlElement element}) async {
    final documentSections = <WisDocumentSection>[];

    final elements = element.findElements('sit');

    for (final documentSection in elements) {
      final id = documentSection.getAttribute('id');
      final number = documentSection.getAttribute('num');
      final name = documentSection.getElement('name')?.innerText;

      if (id == null || number == null || name == null) {
        throw 'The document section must have an id, number, and name. Values: id=$id, number=$number, name=$name';
      }

      final documents = await _parseDocuments(element: documentSection);

      final wisDocumentSection = WisDocumentSection(
        id: id,
        number: number,
        type: WisDocumentSectionType.fromString(name),
        documents: documents,
      );

      documentSections.add(wisDocumentSection);
    }

    return documentSections.isNotEmpty ? documentSections : null;
  }

  Future<List<WisDocument>> _parseDocuments({required XmlElement element}) async {
    final documents = <WisDocument>[];

    final elements = element.findElements('sie');

    for (final document in elements) {
      final id = document.getAttribute('id');
      final documentId = document.getAttribute('docid');
      final name = document.getElement('name')?.innerText;

      if (id == null || documentId == null || name == null) {
        throw 'The document must have an id and documentId. Values: id=$id, documentId=$documentId, name=$name';
      }

      final wisDocument = WisDocument(
        id: id,
        documentId: documentId,
        name: name,
      );

      documents.add(wisDocument);
    }

    return documents;
  }

  Future<void> _parseEcms({required String basePath}) async {
    final modifiedPath = basePath.replaceAll('.xml', 'ECM.xml');
    final ecmParser = WisEcmParser();
    final ecms = await ecmParser.parse(modifiedPath);

    modelData.ecms.addAll(ecms);
  }
}
