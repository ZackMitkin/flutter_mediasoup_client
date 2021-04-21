import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Media kind ('audio' or 'video').
enum MediaKind { audio, video, application }

/// The RTP capabilities define what mediasoup or an endpoint can receive at
/// media level.
class RtpCapabilities {
  /// Supported media and RTX codecs.
  List<RtpCodecCapability>? codecs;

  /// Supported RTP header extensions.
  List<RtpHeaderExtension>? headerExtensions;

  /// Supported FEC mechanisms.
  List<String>? fecMechanisms;
}

/// Direction of RTP header extension.
enum RtpHeaderExtensionDirection { sendrecv, sendonly, recvonly, inactive }

/// Provides information on RTCP feedback messages for a specific codec. Those
/// messages can be transport layer feedback messages or codec-specific feedback
/// messages. The list of RTCP feedbacks supported by mediasoup is defined in the
/// supportedRtpCapabilities.ts file.
class RtcpFeedback {
  ///  RTCP feedback type.
  late String type;

  ///  RTCP feedback parameter.
  String? parameter;
}

/// Provides information on the capabilities of a codec within the RTP
/// capabilities. The list of media codecs supported by mediasoup and their
/// settings is defined in the supportedRtpCapabilities.ts file.
///
/// Exactly one RtpCodecCapability will be present for each supported combination
/// of parameters that requires a distinct value of preferredPayloadType. For
/// example:
///
/// - Multiple H264 codecs, each with their own distinct 'packetization-mode' and
///   'profile-level-id' values.
/// - Multiple VP9 codecs, each with their own distinct 'profile-id' value.
///
/// RtpCodecCapability entries in the mediaCodecs array of RouterOptions do not
/// require preferredPayloadType field (if unset, mediasoup will choose a random
/// one). If given, make sure it's in the 96-127 range.
class RtpCodecCapability {
  /// Media Kind
  late MediaKind kind;

  /// The codec MIME media type/subtype (e.g. 'audio/opus', 'video/VP8').
  late String mimeType;

  /// The preferred RTP payload type.
  int? preferredPayloadType;

  /// Codec clock rate expressed in Hertz.
  late int clockRate;

  /// The number of channels supported (e.g. two for stereo). Just for audio.
  /// Default 1.
  int? channels;

  ///  Codec specific parameters. Some parameters (such as 'packetization-mode'
  ///  and 'profile-level-id' in H264 or 'profile-id' in VP9) are critical for
  ///  codec matching.
  Map<String, dynamic>? parameters;

  List<RtcpFeedback>? rtcpFeedback;
}

/// Provides information relating to supported header extensions. The list of
/// RTP header extensions supported by mediasoup is defined in the
/// supportedRtpCapabilities.ts file.
///
/// mediasoup does not currently support encrypted RTP header extensions. The
/// direction field is just present in mediasoup RTP capabilities (retrieved via
/// router.rtpCapabilities or mediasoup.getSupportedRtpCapabilities()). It's
/// ignored if present in endpoints' RTP capabilities.
class RtpHeaderExtension {
  /// Media kind. If empty string, it's valid for all kinds.
  /// Default any media kind.
  MediaKind? kind;

  /// The URI of the RTP header extension, as defined in RFC 5285.
  late String uri;

  /// The preferred numeric identifier that goes in the RTP packet. Must be
  /// unique.
  late int preferredId;

  /// If true, it is preferred that the value in the header be encrypted as per
  /// RFC 6904. Default false.
  bool? preferredEncrypt;

  /// If 'sendrecv', mediasoup supports sending and receiving this RTP extension.
  /// 'sendonly' means that mediasoup can send (but not receive) it. 'recvonly'
  /// means that mediasoup can receive (but not send) it.
  RtpHeaderExtensionDirection? direction;
}

/// The RTP send parameters describe a media stream received by mediasoup from
/// an endpoint through its corresponding mediasoup Producer. These parameters
/// may include a mid value that the mediasoup transport will use to match
/// received RTP packets based on their MID RTP extension value.
///
/// mediasoup allows RTP send parameters with a single encoding and with multiple
/// encodings (simulcast). In the latter case, each entry in the encodings array
/// must include a ssrc field or a rid field (the RID RTP extension value). Check
/// the Simulcast and SVC sections for more information.
///
/// The RTP receive parameters describe a media stream as sent by mediasoup to
/// an endpoint through its corresponding mediasoup Consumer. The mid value is
/// unset (mediasoup does not include the MID RTP extension into RTP packets
/// being sent to endpoints).
///
/// There is a single entry in the encodings array (even if the corresponding
/// producer uses simulcast). The consumer sends a single and continuous RTP
/// stream to the endpoint and spatial/temporal layer selection is possible via
/// consumer.setPreferredLayers().
///
/// As an exception, previous bullet is not true when consuming a stream over a
/// PipeTransport, in which all RTP streams from the associated producer are
/// forwarded verbatim through the consumer.
///
/// The RTP receive parameters will always have their ssrc values randomly
/// generated for all of its  encodings (and optional rtx: { ssrc: XXXX } if the
/// endpoint supports RTX), regardless of the original RTP send parameters in
/// the associated producer. This applies even if the producer's encodings have
/// rid set.
class RtpParameters {
  /// The MID RTP extension value as defined in the BUNDLE specification.
  String? mid;

  /// Media and RTX codecs in use.
  late List<RtpCodecParameters> codecs;

  /// RTP header extensions in use.
  List<RtpHeaderExtensionParameters>? headerExtensions;

  /// Transmitted RTP streams and their settings.
  List<RtpEncodingParameters>? encodings;

  /// Parameters used for RTCP.
  RtcpParameters? rtcp;
}

class RtcpParameters {
  /// The Canonical Name (CNAME) used by RTCP (e.g. in SDES messages).
  String? cname;

  /// Whether reduced size RTCP RFC 5506 is configured (if true) or compound RTCP
  /// as specified in RFC 3550 (if false). Default true.
  bool? reducedSize;

  /// Whether RTCP-mux is used. Default true.
  bool? mux;
}

/// Provides information relating to an encoding, which represents a media RTP
/// stream and its associated RTX stream (if any).
class RtpEncodingParameters {
  /// The media SSRC.
  int? ssrc;

  /// The RID RTP extension value. Must be unique.
  String? rid;

  /// Codec payload type this encoding affects. If unset, first media codec is
  /// chosen.
  int? codecPayloadType;

  /// RTX stream information. It must contain a numeric ssrc field indicating
  /// the RTX SSRC.
  Rtx? rtx;

  /// It indicates whether discontinuous RTP transmission will be used. Useful
  /// for audio (if the codec supports it) and for video screen sharing (when
  /// static content is being transmitted, this option disables the RTP
  /// inactivity checks in mediasoup). Default false.
  bool? dtx;

  /// Number of spatial and temporal layers in the RTP stream (e.g. 'L1T3').
  /// See webrtc-svc.
  String? scalabilityMode;

  /// Others.
  int? scaleResolutionDownBy;
  int? maxBitrate;
  int? maxFramerate;
  bool? adaptivePtime;
  Priority? priority;
  Priority? networkPriority;
}

enum Priority { veryLow, low, medium, high }

class Rtx {
  late int ssrc;
}

/// Defines a RTP header extension within the RTP parameters. The list of RTP
/// header extensions supported by mediasoup is defined in the
/// supportedRtpCapabilities.dart file.
///
/// mediasoup does not currently support encrypted RTP header extensions and no
/// parameters are currently considered.
class RtpHeaderExtensionParameters {
  /// The URI of the RTP header extension, as defined in RFC 5285.
  late String uri;

  /// The numeric identifier that goes in the RTP packet. Must be unique.
  late int id;

  /// If true, the value in the header is encrypted as per RFC 6904. Default false.
  bool? encrypt;

  /// Configuration parameters for the header extension.
  dynamic? parameters;
}

/// Provides information on codec settings within the RTP parameters. The list
/// of media codecs supported by mediasoup and their settings is defined in the
/// supportedRtpCapabilities.dart file.
class RtpCodecParameters {
  /// The codec MIME media type/subtype (e.g. 'audio/opus', 'video/VP8').
  late String mimeType;

  /// The value that goes in the RTP Payload Type Field. Must be unique.
  late int payloadType;

  /// Codec clock rate expressed in Hertz.
  late int clockRate;

  /// The number of channels supported (e.g. two for stereo). Just for audio.
  /// Default 1.
  int? channels;

  /// Codec-specific parameters available for signaling. Some parameters (such
  /// as 'packetization-mode' and 'profile-level-id' in H264 or 'profile-id' in
  /// VP9) are critical for codec matching.
  dynamic? parameters;

  /// Transport layer and codec-specific feedback messages for this codec.
  List<RtcpFeedback>? rtcpFeedback;
}
