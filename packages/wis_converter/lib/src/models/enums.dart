
enum FileType {
  none._('None', ''),
  xml._('XML', '.xml'),
  html._('HTML', '.html'),
  zip._('ZIP', '.zip'),
  ;

  final String name;
  final String extension;

  const FileType._(this.name, this.extension);

  static FileType fromString(String type) {
    switch (type) {
      case 'xml':
        return FileType.xml;
      case 'html':
        return FileType.html;
      case 'zip':
        return FileType.zip;
      default:
        return none;
    }
  }
}
