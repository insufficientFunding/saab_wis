export 'wis_parser.dart';

abstract class XmlParser<T> {
  Future<T> parse(String path);
}
