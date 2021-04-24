import 'package:eventify/eventify.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mediasoup_client/src/handlers/common_utils.dart';
import 'package:flutter_mediasoup_client/src/ortc.dart';
import 'package:flutter_mediasoup_client/src/remote_sdp.dart';
import 'package:flutter_mediasoup_client/src/rtp_parameters.dart';
import 'package:flutter_mediasoup_client/src/sctp_parameters.dart';
import 'package:flutter_mediasoup_client/src/transport.dart';
import 'package:flutter_mediasoup_client/src/utils/enhanced_event_emitter.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart' as sdp_transform;

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

class Handler extends EnhancedEventEmitter {
  // Handler direction.
  String? direction; // send | recv
  // Remote SDP handler.
  RemoteSdp? remoteSdp;

  // Generic sending RTP parameters for audio and video.
  Map<String, RtpParameters>? sendingRtpParametersByKind;

  // Generic sending RTP parameters for audio and video suitable for the SDP
  // remote answer.
  Map<String, RtpParameters>? sendingRemoteRtpParametersByKind;

  // RTCPeerConnection instance.
  RTCPeerConnection? pc;

  // Map of RTCTransceivers indexed by MID.
  Map<String, RTCRtpTransceiver>? mapMidTransceiver = {};

  // Local stream for sending.
  //final sendStream = MediaStream();

  // Whether a DataChannel m=application section has been created.
  bool hasDataChannelMediaSection = false;

  // Sending DataChannel id value counter. Incremented for each new DataChannel.
  int nextSendSctpStreamId = 0;

  // Got transport local and remote parameters.
  bool transportReady = false;

  Handler() : super();

  close() {
    if (pc != null) {
      try {
        pc!.close();
      } catch (error) {}
    }
  }

  Future<RtpCapabilities> getNativeRtpCapabilities() async {
    final configuration = {
      'iceServers': [],
      'iceTransportPolicy': 'all',
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
      'sdpSemantics': 'unified-plan'
    };

    final offerSdpConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': false,
        'OfferToReceiveVideo': false,
      },
      'optional': [],
    };

    final constraints = <String, dynamic>{
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ],
    };

    try {
      pc = await createPeerConnection(configuration, constraints);
      final offer = await pc!.createOffer(offerSdpConstraints);

      try {
        await pc!.close();
      } catch (error) {}

      var sdpObject = sdp_transform.parse(offer.sdp!);
      return extractRtpCapabilities(sdpObject);
    } catch (error) {
      try {
        await pc!.close();
      } catch (error2) {}

      rethrow;
    }
  }

  void run(
      {required String direction,
      required IceParameters iceParameters,
      required List<IceCandidate> iceCandidates,
      required DtlsParameters dtlsParameters,
      SctpParameters? sctpParameters,
      List<RTCIceServer>? iceServers,
      RTCIceTransportPolicy? iceTransportPolicy,
      Map<String, dynamic>? additionalSettings,
      dynamic proprietaryConstraints,
      dynamic extendedRtpCapabilities}) async {
    this.direction = direction;

    remoteSdp = RemoteSdp(
        iceParameters: iceParameters,
        iceCandidates: iceCandidates,
        dtlsParameters: dtlsParameters,
        sctpParameters: sctpParameters);

    sendingRtpParametersByKind = {
      'audio':
          getSendingRtpParameters(MediaKind.audio, extendedRtpCapabilities),
      'video': getSendingRtpParameters(MediaKind.video, extendedRtpCapabilities)
    };

    sendingRemoteRtpParametersByKind = {
      'audio': getSendingRemoteRtpParameters(
          MediaKind.audio, extendedRtpCapabilities),
      'video': getSendingRemoteRtpParameters(
          MediaKind.video, extendedRtpCapabilities)
    };

    final configuration = {
      'iceServers': iceServers,
      'iceTransportPolicy':
          describeEnum(iceTransportPolicy ?? RTCIceTransportPolicy.all),
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
      'sdpSemantics': 'unified-plan',
      ...additionalSettings ?? {}
    };

    pc = await createPeerConnection(configuration, proprietaryConstraints);

    pc!.onIceConnectionState = (state) {
      switch (state) {
        case RTCIceConnectionState.RTCIceConnectionStateChecking:
          emit('@connectionstatechange', 'connecting');
          break;
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
        case RTCIceConnectionState.RTCIceConnectionStateCompleted:
          emit('@connectionstatechange', 'connected');
          break;
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          emit('@connectionstatechange', 'failed');
          break;
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
          emit('@connectionstatechange', 'disconnected');
          break;
        case RTCIceConnectionState.RTCIceConnectionStateClosed:
          emit('@connectionstatechange', 'closed');
          break;
        default:
          break;
      }
    };
  }
}
