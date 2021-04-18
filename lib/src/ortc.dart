import 'package:flutter_mediasoup_client/src/RtpParameters.dart';

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
