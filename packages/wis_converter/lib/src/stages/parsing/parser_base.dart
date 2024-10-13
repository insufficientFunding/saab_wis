import 'dart:async';

import 'package:wis_converter/src/stages/splitting/split_result.dart';

abstract class Parser {
  /// Parse the given [SplitResult].
  Future<void> parse(SplitResult result);
}
