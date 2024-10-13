import 'package:test/test.dart';

import '../bin/wis_converter.dart' as wis_converter;

void main() {
  test('Split', () async {
    await wis_converter.main(['split', '~/Wis/', 'wis_output/']);
  });
}
