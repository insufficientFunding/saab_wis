import 'package:test/test.dart';
import 'package:wis_base/wis_base.dart';
import 'package:wis_navigation/wis_navigation.dart';

void main() {
  test('xml parser', () async {
    const model = Model.nineThreeNG;
    const language = Language.english;
    const year = '2008';

    final parser = WisXmlParser();

    final path = '../../wis_output/${model.toString()}/${language.name}/$year.xml';

    await parser.parse(Path.parsePath(path));
  });
}
