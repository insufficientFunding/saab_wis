import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:wis_base/wis_base.dart';

class DocumentParserResult {
  final String data;
  final String? error;
  final String? debug;

  const DocumentParserResult({required this.data, this.error, this.debug});
}

class DocumentParser {
  Future<DocumentParserResult> load({required Model model, required Language language, required String docId}) async {
    final path = getDocumentId(model: model, language: language, docId: docId);
    var data = await File(path).readAsString();

    // final result = _parseDocument(data);

    data = data.replaceAll('color:black;', '');
    // data = data.replaceAll('font-family:Verdana;', 'font-family:inherit;');

    return DocumentParserResult(data: data, error: null, debug: '');
  }

  String getDocumentId({required Model model, required Language language, required String docId}) {
    final path = 'wis_output/${model.toString()}/${language.name}/doc/';

    final documentIdWithoutLetters = docId.replaceAll(RegExp(r'[a-zA-Z]'), '');
    var idWithoutLastThreeDigits = documentIdWithoutLetters.substring(0, documentIdWithoutLetters.length - 3);
    if (idWithoutLastThreeDigits.isEmpty) {
      idWithoutLastThreeDigits = '0';
    }
    if (idWithoutLastThreeDigits.length == 3) {
      idWithoutLastThreeDigits = idWithoutLastThreeDigits.substring(0, 2);
    }

    final documentPath = '$path$idWithoutLastThreeDigits/doc${docId.toLowerCase()}.htm';

    return Path.parsePath(documentPath);
  }

  DocumentParserResult _parseDocument(String data) {
    // First we need to remove the <SCRIPT> tags and their content.
    var document = data.replaceAllMapped(RegExp(r"""\s*style\s*=\s*['"][^'"]*['"]""", caseSensitive: false), (match) {
      if (match.group(0)!.contains('font-weight:bold;')) {
        return " style='font-weight:bold;'";
      }

      return '';
    }).replaceAll(RegExp(r'<br>', caseSensitive: false), '\n');
    //remove all script tags
    document = document.replaceAll(RegExp(r"""<SCRIPT[^>]*>.*?</SCRIPT>""", caseSensitive: false), '');

    String? xmlError;
    StringBuffer xmlDebug = StringBuffer();
    try {
      final xmlReader = parse(document);
      xmlReader.getElementsByTagName('head').forEach((element) => element.remove());
      xmlReader.getElementsByTagName('meta').forEach((element) => element.remove());
      // Now we want to isolate the innermost text of the body tag's children.
      xmlReader.getElementsByTagName('body').forEach((element) {
        document = element.children
            .expand((e) => _recursiveExpand(node: e))
            .map((node) {
              _buildDebugString(node, xmlDebug);
              return _formatElement(node);
            })
            // Limit the number of consecutive line breaks to 2.
            .map((e) => e?.replaceAll(RegExp(r'\n{3,}'), '\n\n'))
            .map((e) {
              if (e == null) return null;
              return e.replaceAllMapped(RegExp(r'^\d+\.'), (match) => '${match.group(0)} ');
            })
            .where((e) => e != null && e != 'null')
            .join('\n');
      });
      // // Then we select the first line of the document, and add '# ' to the beginning of it.
      // // This is to make the first line a header in markdown.
      final firstLine = document.split('\n').first;
      document = document.replaceFirst(firstLine, firstLine.replaceAll('##', '#'));

      // document = xmlReader.outerHtml;
    } catch (e) {
      xmlError = e.toString();
    }

    return DocumentParserResult(data: document, error: xmlError, debug: xmlDebug.toString());
  }

  String? _formatElement(Element node) {
    final nodeName = node.localName?.toLowerCase();
    if ((nodeName == 'span' && node.nodes.length > 1) || nodeName == 'div') {
      return node.children.map((e) => _formatElement(e)).where((e) => e != null).join('\n');
    }

    final text = _recursivelyGetInnerText(node: node);
    if (node.attributes['bgcolor'] == '#6699cc' || node.localName?.toLowerCase() == 'h2') {
      return text != null ? '## $text' : null;
    }

    if (node.attributes['bgcolor'] == 'f8f8f8' && text != null) {
      final regExp = RegExp(r'^\s+', multiLine: true);
      final textWithoutLeadingSpaces = text.replaceAll(regExp, '');
      return textWithoutLeadingSpaces.replaceAll(RegExp(r'^', multiLine: true), '> ');
    }
    return text;
  }

  String? _recursivelyGetInnerText({required Element node, bool isBold = false}) {
    if (node.localName?.toLowerCase() == 'br') {
      return '\n';
    }

    isBold = isBold ? isBold : node.attributes['style']?.contains('font-weight:bold;') ?? false;
    if (node.children.isEmpty) {
      final text = node.text.trim();
      if (text.isEmpty) return null;
      return isBold ? '**$text**' : text;
    }

    String? text;
    for (var child in node.children) {
      final childText = _recursivelyGetInnerText(node: child, isBold: isBold);
      if (childText != null && childText.isNotEmpty) {
        text ??= '';
        text += '$childText\n';
      }
    }

    return text;
  }

  List<Element> _recursiveExpand({required Element node}) {
    final isText = node.nodes.map((e) => e.nodeType == Node.TEXT_NODE);
    if (isText.contains(true) && isText.contains(false)) {
      final newNode = node.clone(false);
      newNode.nodes.addAll(node.nodes.where((e) => e.nodeType != Node.TEXT_NODE));

      final textNode = node.clone(false);
      textNode.text = node.nodes.where((e) => e.nodeType == Node.TEXT_NODE).map((e) => e.text).join();

      return [
        textNode,
        newNode,
      ];
    }
    final isDiv = node.localName?.toLowerCase() == 'div';
    if (isDiv) {
      return node.children.expand((e) => _recursiveExpand(node: e)).toList();
    }

    // final isSpan = node.localName?.toLowerCase() == 'span';
    // final children = node.children;
    // if (isSpan) {
    //   if (node.nodes.every((e) => e.nodeType == Node.TEXT_NODE)) {
    //     return [node];
    //   }
    //   return children.expand((e) => _recursiveExpand(node: e)).toList();
    // }

    return [node];
  }

  void _buildDebugString(Element node, StringBuffer debug, {int depth = 1}) {
    final nodeName = node.localName?.toLowerCase();
    final children = node.children;
    final textNodes = node.nodes.where((e) => e.nodeType == Node.TEXT_NODE).map((e) => e.text).join('\n');

    final text = textNodes.trim().isNotEmpty ? textNodes : null;
    final header = '${'    ' * depth}L ';
    debug.writeln('${depth == 1 ? '' : header}<$nodeName>');
    if (text != null) {
      debug.writeln('    $header<text>${text.trim()}</text>');
    }
    if (children.isNotEmpty) {
      for (var child in children) {
        _buildDebugString(child, debug, depth: depth + 1);
      }
    }
  }
}
