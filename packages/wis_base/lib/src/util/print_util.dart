abstract class PrintUtil {
  static String color(String text, PrintColor color, {bool bright = true}) {
    return '\x1B[${color.value}${bright ? ';1' : ''}m$text\x1B[0m';
  }
}

enum PrintColor {
  black('30'),
  red('31'),
  green('32'),
  yellow('33'),
  blue('34'),
  magenta('35'),
  cyan('36'),
  white('37'),
  reset();

  final String value;

  const PrintColor([this.value = '']);
}
