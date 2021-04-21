import 'package:flutter_mediasoup_client/src/sctp_parameters.dart';
import 'package:flutter_mediasoup_client/src/transport.dart';

class RemoteSdp {
  /// Remote ICE parameters.
  IceParameters? iceParameters;

  /// Remote ICE candidates.
  List<IceCandidate>? iceCandidates;

  /// Remote DTLS parameters.
  DtlsParameters? dtlsParameters;

  /// Remote SCTP parameters.
  SctpParameters? sctpParameters;

  /// Parameters for plain RTP (no SRTP nor DTLS no BUNDLE). Fields:
  PlainRtpParameters? plainRtpParameters;
  bool planB = false;

  // MediaSection instances indexed by MID.
  Map<String, AnswerMediaSection> _mediaSections =
      Map<String, AnswerMediaSection>();
}
