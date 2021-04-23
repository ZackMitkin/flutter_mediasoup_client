import 'package:flutter_mediasoup_client/src/media_section.dart';
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

  /// Whether this is Plan-B SDP.
  late final bool planB;

  /// MediaSection instances with same order as in the SDP.
  late final List<MediaSection> mediaSections;

  /// MediaSection indices indexed by MID.
  late final Map<String, int> midToIndex = {};

  /// First MID.
  String? firstMid;

  /// SDP object.
  dynamic sdpObject;

  RemoteSdp(
      {this.iceParameters,
      this.iceCandidates,
      this.dtlsParameters,
      this.sctpParameters,
      this.plainRtpParameters,
      this.planB = false}) {
    sdpObject = {
      'version': 0,
      'origin': {
        'address': '0.0.0.0',
        'ipVer': 4,
        'netType': 'IN',
        'sessionId': 10000,
        'sessionVersion': 0,
        'username': 'mediasoup-client'
      },
      'name': '-',
      'timing': {'start': 0, 'stop': 0},
      'media': []
    };

    // If ICE parameters are given, add ICE-Lite indicator.
    if (iceParameters != null && iceParameters!.iceLite != null) {
      sdpObject['icelite'] = 'ice-lite';
    }

    // If DTLS parameters are given, assume WebRTC and BUNDLE.
    if (dtlsParameters != null) {
      sdpObject['msidSemantic'] = {'semantic': 'WMS', 'token': '*'};

      // NOTE: We take the latest fingerprint.
      final numFingerprints = dtlsParameters!.fingerprints.length;

      sdpObject['fingerprint'] = {
        'type': dtlsParameters!.fingerprints[numFingerprints - 1].algorithm,
        'hash': dtlsParameters!.fingerprints[numFingerprints - 1].value
      };

      sdpObject['groups'] = [
        {'type': 'BUNDLE', 'mids': ''}
      ];
    }

    // If there are plain RPT parameters, override SDP origin.
    if (plainRtpParameters != null) {
      sdpObject['origin']['address'] = plainRtpParameters!.ip;
      sdpObject['origin']['ipVer'] = plainRtpParameters!.ipVersion;
    }
  }

  void updateIceParameters(IceParameters iceParameters) {
    this.iceParameters = iceParameters;
    sdpObject['icelite'] = iceParameters.iceLite != null ? 'ice-lite' : null;

    for (final mediaSection in mediaSections) {
      mediaSection.setIceParameters(iceParameters);
    }
  }

  void updateDtlsRole(DtlsRole role) {
    dtlsParameters!.role = role;

    for (final mediaSection in mediaSections) {
      mediaSection.setDtlsRole(role);
    }
  }
}
