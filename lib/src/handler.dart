import 'package:eventify/eventify.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ScalabilityMode {
  static final scalabilityModeRegex =
      RegExp('^[LS]([1-9]\\d{0,1})T([1-9]\\d{0,1})');

  late final int spatialLayers;
  late final int temporalLayers;

  ScalabilityMode({required this.spatialLayers, required this.temporalLayers});
}

ScalabilityMode parseScalabilityMode(String scalabilityMode) {
  var matches =
      ScalabilityMode.scalabilityModeRegex.allMatches(scalabilityMode);

  if (matches.isNotEmpty) {
    var match = matches.first;
    return ScalabilityMode(
        spatialLayers: int.parse(match[1]!),
        temporalLayers: int.parse(match[2]!));
  } else {
    return ScalabilityMode(spatialLayers: 1, temporalLayers: 1);
  }
}

