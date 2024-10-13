enum Model {
  none._('None'),
  nineThreeNG._('9-3 (9440)');

  final String name;

  const Model._(this.name);

  static Model fromString(String model) {
    switch (model) {
      case '9_3ng':
        return Model.nineThreeNG;
      default:
        throw 'The model $model is not supported.';
    }
  }

  static Model fromName(String name) {
    switch (name) {
      case '9-3 (9440)':
        return Model.nineThreeNG;
      default:
        throw 'The model $name is not supported.';
    }
  }

  @override
  String toString() => name.replaceAll(' ', '-').replaceAll('(', '').replaceAll(')', '');
}
