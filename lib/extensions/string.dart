extension StringExtensions on String {
  String toLowerNoSpaces() {
    return this.toLowerCase().replaceAll(' ', '');
  }
}

abstract class StringUtil {
  static bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }
}
