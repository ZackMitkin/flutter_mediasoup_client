import 'package:flutter/foundation.dart';
import 'package:flutter_mediasoup_client/src/rtp_parameters.dart';

void validateRtpCapabilities(RtpCapabilities caps) {
  // codecs is optional. If unset, fill with an empty array.
  caps.codecs ??= [];

  for (var codec in caps.codecs!) {
    validateRtpCodecCapability(codec);
  }

  // headerExtensions is optional. If unset, fill with an empty array.
  caps.headerExtensions ??= [];

  for (var ext in caps.headerExtensions!) {
    validateRtpHeaderExtension(ext);
  }
}

/// Validates RtpCodecCapability. It may modify given data by adding missing
/// fields with default values.
/// It throws if invalid.
void validateRtpCodecCapability(RtpCodecCapability codec) {
  final mimeTypeVideoRegex = RegExp('^(video)/(.+)');
  final mimeTypeAudioRegex = RegExp('^(audio)/(.+)');

  if (mimeTypeVideoRegex.hasMatch(codec.mimeType)) {
    codec.kind = MediaKind.video;
  } else if (mimeTypeAudioRegex.hasMatch(codec.mimeType)) {
    codec.kind = MediaKind.audio;
  } else {
    throw Exception('invalid codec.mimeType');
  }

  // channels is optional. If unset, set it to 1 (just if audio).
  if (codec.kind == MediaKind.audio) {
    codec.channels ??= 1;
  } else {
    codec.channels = null;
  }

  // parameters is optional. If unset, set it to an empty object.
  codec.parameters ??= {};

  for (final key in codec.parameters!.keys) {
    var value = codec.parameters![key];

    if (value == null) {
      codec.parameters![key] = '';
      value = '';
    }

    if (!value is int || !value is String) {
      throw Exception('invalid codec parameter [key:${key}s, value:$value]');
    }

    // Specific parameters validation.
    if (key == 'apt') {
      if (!value is int) throw Exception('invalid codec apt parameter');
    }
  }

  // rtcpFeedback is optional. If unset, set it to an empty array.
  codec.rtcpFeedback ??= [];

  for (var fb in codec.rtcpFeedback!) {
    validateRtcpFeedback(fb);
  }
}

/// Validates RtcpFeedback. It may modify given data by adding missing
/// fields with default values.
/// It throws if invalid.
void validateRtcpFeedback(RtcpFeedback fb) {
  // TODO: Implement some better validation
  fb.parameter ??= '';
}

/// Validates RtpHeaderExtension. It may modify given data by adding missing
/// fields with default values.
/// It throws if invalid.
void validateRtpHeaderExtension(RtpHeaderExtension ext) {
  ext.preferredEncrypt ??= false;
  ext.direction ??= RtpHeaderExtensionDirection.sendrecv;
}

/// Generate RTP parameters of the given kind suitable for the remote SDP
/// answer.
RtpParameters getSendingRemoteRtpParameters(
    MediaKind mediaKind, dynamic extendedRtpCapabilities) {
  final kind = describeEnum(mediaKind);
  final rtpParameters = RtpParameters(
      codecs: [], encodings: [], headerExtensions: [], rtcp: RtcpParameters());

  for (final extendedCodec in extendedRtpCapabilities['codecs']) {
    if (extendedCodec.kind != kind) continue;

    final codec = RtpCodecParameters(
        mimeType: extendedCodec['mimeType'],
        payloadType: extendedCodec['localPayloadType'],
        clockRate: extendedCodec['clockRate'],
        channels: extendedCodec['channels'],
        parameters: extendedCodec['remoteParameters'],
        rtcpFeedback: extendedCodec['rtcpFeedback']);

    rtpParameters.codecs.add(codec);

    // Add RTX codec.
    if (extendedCodec['localRtxPayloadType'] != null) {
      final rtxCodec = RtpCodecParameters(
          mimeType: '${extendedCodec.kind}/rtx',
          payloadType: extendedCodec['localRtxPayloadType'],
          clockRate: extendedCodec['clockRate'],
          rtcpFeedback: [],
          parameters: {'apt': extendedCodec['localPayloadType']});

      rtpParameters.codecs.add(rtxCodec);
    }
  }

  for (final extendedExtension in extendedRtpCapabilities['headerExtensions']) {
    // Ignore RTP extensions of a different kind and
    // those not valid for sending.
    if ((extendedExtension['kind'] != null &&
            extendedExtension['kind'] != kind) ||
        (extendedExtension['direction'] != 'sendrecv' &&
            extendedExtension['direction'] != 'sendonly')) {
      continue;
    }

    final ext = RtpHeaderExtensionParameters(
        uri: extendedExtension['uri'],
        id: extendedExtension['sendId'],
        encrypt: extendedExtension['encrypt'],
        parameters: {});

    rtpParameters.headerExtensions!.add(ext);
  }

  // Reduce codecs' RTCP feedback. Use Transport-CC if available,
  // REMB otherwise.
  if (rtpParameters.headerExtensions!
      .where((ext) =>
          ext.uri ==
          "'http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01")
      .isNotEmpty) {
    for (final codec in rtpParameters.codecs) {
      codec.rtcpFeedback = (codec.rtcpFeedback ?? [])
          .where((fb) => fb.type != 'goog-remb')
          .toList();
    }
  } else if (rtpParameters.headerExtensions!
      .where((ext) =>
          ext.uri ==
          'http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time')
      .isNotEmpty) {
    for (final codec in rtpParameters.codecs) {
      codec.rtcpFeedback = (codec.rtcpFeedback ?? [])
          .where((fb) => fb.type != 'transport-cc')
          .toList();
    }
  } else {
    for (final codec in rtpParameters.codecs) {
      codec.rtcpFeedback = (codec.rtcpFeedback ?? [])
          .where((fb) => fb.type != 'transport-cc' && fb.type != 'goog-remb')
          .toList();
    }
  }
  return rtpParameters;
}

RtpParameters getSendingRtpParameters(
    MediaKind mediaKind, dynamic extendedRtpCapabilities) {
  final kind = describeEnum(mediaKind);
  final rtpParameters = RtpParameters(
      codecs: [],
      headerExtensions: [],
      rtcp: RtcpParameters(),
      encodings: [],
      mid: null);

  for (final extendedCodec in extendedRtpCapabilities['codecs']) {
    if (extendedCodec['kind'] != kind) continue;

    final codec = RtpCodecParameters(
        mimeType: extendedCodec['mimeType'],
        payloadType: extendedCodec['localPayloadType'],
        clockRate: extendedCodec['clockRate'],
        channels: extendedCodec['channels'],
        parameters: extendedCodec['remoteParameters'],
        rtcpFeedback: extendedCodec['rtcpFeedback']);

    rtpParameters.codecs.add(codec);

    // Add RTX codec.
    if (extendedCodec['localRtxPayloadType'] != null) {
      final rtxCodec = RtpCodecParameters(
          mimeType: '${extendedCodec.kind}/rtx',
          payloadType: extendedCodec['localRtxPayloadType'],
          clockRate: extendedCodec['clockRate'],
          rtcpFeedback: [],
          parameters: {'apt': extendedCodec['localPayloadType']});

      rtpParameters.codecs.add(rtxCodec);
    }
  }

  for (final extendedExtension in extendedRtpCapabilities['headerExtensions']) {
    // Ignore RTP extensions of a different kind
    // and those not valid for sending.
    if ((extendedExtension['kind'] && extendedExtension.kind != kind) ||
        (extendedExtension.direction != 'sendrecv' &&
            extendedExtension.direction != 'sendonly')) {
      continue;
    }

    final ext = RtpHeaderExtensionParameters(
        uri: extendedExtension['uri'],
        id: extendedExtension['sendId'],
        encrypt: extendedExtension['encrypt'],
        parameters: {});

    rtpParameters.headerExtensions!.add(ext);
  }

  return rtpParameters;
}
