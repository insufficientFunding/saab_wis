import 'package:wis_base/src/models/ecm/dtc.dart';
export 'package:wis_base/src/models/ecm/dtc.dart';

class WisEcm {
  final String id;
  final String name;

  final List<WisDtc> dtcs;

  WisEcm({
    required this.id,
    required this.name,
    List<WisDtc>? dtcs,
  }) : dtcs = dtcs ?? <WisDtc>[];
}
