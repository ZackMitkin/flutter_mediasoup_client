import 'package:flutter_mediasoup_client/src/rtp_parameters.dart';
import 'package:sdp_transform/sdp_transform.dart' as sdp_transform;

RtpCapabilities extractRtpCapabilities(dynamic sdpObject) {
  // Map of RtpCodecParameters indexed by payload type.
  var codecsMap = <int, RtpCodecCapability>{};
  // Array of RtpHeaderExtensions.
  var headerExtensions = <RtpHeaderExtension>[];
  // Whether a m=audio/video section has been already found.
  var gotAudio = false;
  var gotVideo = false;

  for (final m in sdpObject['media']) {
    final kind = m['type'];
    switch (kind) {
      case 'audio':
        {
          if (gotAudio) continue;

          gotAudio = true;

          break;
        }
      case 'video':
        {
          if (gotVideo) continue;

          gotVideo = true;

          break;
        }
      default:
        {
          continue;
        }
    }

    // Get codecs.
    for (final rtp in m['rtp']) {
      final codec = RtpCodecCapability(
          mimeType: '$kind/${rtp['codec']}',
          kind: kind,
          clockRate: rtp['rate'],
          preferredPayloadType: rtp['payload'],
          channels: rtp['encoding'],
          rtcpFeedback: [],
          parameters: {});

      codecsMap[codec.preferredPayloadType!] = codec;
    }

    // Get codec parameters.
    for (final fmtp in m['fmtp'] ?? []) {
      final parameters = sdp_transform.parseParams(fmtp['config']);
      var codec = codecsMap[fmtp.payload];

      if (codec == null) continue;

      // Specials case to convert parameter value to string.
      if (parameters.keys.contains('profile-level-id')) {
        parameters['profile-level-id'] = '${parameters['profile-level-id']}';
      }

      codec.parameters = parameters;
    }

    // Get RTCP feedback for each codec.
    for (final fb in m['rtcpFb'] ?? []) {
      final codec = codecsMap[fb['payload']];

      if (codec == null) continue;

      final feedback = RtcpFeedback(type: fb['type'], parameter: fb['subtype']);

      codec.rtcpFeedback!.add(feedback);
    }

    // Get RTP header extensions.
    for (final ext in m.ext ?? []) {
      // Ignore encrypted extensions (not yet supported in mediasoup).
      if (ext['encrypt-uri'] != null) continue;

      final headerExtension = RtpHeaderExtension(
          preferredId: ext['value'], uri: ext['uri'], kind: kind);

      headerExtensions.add(headerExtension);
    }
  }

  final rtpCapabilities = RtpCapabilities(
      codecs: codecsMap.values.toList(), headerExtensions: headerExtensions);

  return rtpCapabilities;
}
