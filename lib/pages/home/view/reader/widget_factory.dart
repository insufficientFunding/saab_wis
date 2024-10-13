import 'package:csslib/visitor.dart' as css;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class WisWidgetFactory extends WidgetFactory {
  @override
  void parseStyle(BuildTree tree, css.Declaration style) {
    if (style.property == 'font-family') {
      if (style.term == 'Verdana') return;
    }

    super.parseStyle(tree, style);
  }
}
