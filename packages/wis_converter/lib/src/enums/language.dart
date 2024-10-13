enum Language {
  none._('None', 'none'),
  english._('English', 'gb'),
  spanish._('Spanish', 'es');

  final String name;
  final String code;

  const Language._(this.name, this.code);

  bool isAtEndOfFile(String line) {
    line = line.split('.').first.toLowerCase().trimRight();
    return line.endsWith(code);
  }

  bool isAtStartOfFile(String line) {
    line = line.split('.').first.toLowerCase().trimLeft();
    return line.startsWith(code);
  }

  static Language fromString(String language) {
    language = language.toLowerCase();
    switch (language) {
      case 'gb':
        return Language.english;
      case 'es':
        return Language.spanish;
      default:
        throw 'The language $language is not supported.';
    }
  }
}
