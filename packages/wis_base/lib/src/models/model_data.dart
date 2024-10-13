import 'package:equatable/equatable.dart';
import 'package:wis_base/wis_base.dart';

class WisModelData extends Equatable {
  final Model model;
  final Language language;
  final String year;

  final List<WisEcm> ecms;
  final List<WisSection> sections;

  WisModelData({
    required this.model,
    required this.language,
    required this.year,
  })  : sections = [],
        ecms = [];

  @override
  // TODO: implement props
  List<Object?> get props => [model, language, year, ecms, sections];
}
