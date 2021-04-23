import 'package:flutter_mediasoup_client/src/producer.dart';
import 'package:flutter_mediasoup_client/src/rtp_parameters.dart';
import 'package:flutter_mediasoup_client/src/sctp_parameters.dart';
import 'package:flutter_mediasoup_client/src/transport.dart';
import 'dart:convert';

abstract class MediaSection {
  /// SDP media object.
  late Map<String, dynamic> mediaObject;

  /// Whether this is Plan-B SDP.
  dynamic planB;

  MediaSection(
      {required this.planB,
      IceParameters? iceParameters,
      List<IceCandidate>? iceCandidates,
      DtlsParameters? dtlsParameters}) {
    mediaObject = {};

    if (iceParameters != null) {
      setIceParameters(iceParameters);
    }

    if (iceCandidates != null) {
      setIceCandidates(iceCandidates);
    }

    if (dtlsParameters != null) {
      setDtlsRole(dtlsParameters.role!);
    }
  }

  void setDtlsRole(DtlsRole role);

  void setIceParameters(IceParameters iceParameters) {
    mediaObject['iceUfrag'] = iceParameters.usernameFragment;
    mediaObject['icePwd'] = iceParameters.password;
  }

  void setIceCandidates(List<IceCandidate> iceCandidates) {
    mediaObject['candidates'] = [];

    for (var candidate in iceCandidates) {
      dynamic candidateObject = {
        // mediasoup does mandates rtcp-mux so candidates component is always
        // RTP (1).
        'component': 1,
        'foundation': candidate.foundation,
        'ip': candidate.ip,
        'port': candidate.port,
        'priority': candidate.priority,
        'transport': candidate.protocol,
        'type': candidate.type,
      };
      if (candidate.tcpType != null) {
        candidateObject['tcptype'] = candidate.tcpType;
      }
      mediaObject['candidates'].add(candidateObject);
    }
    mediaObject['endOfCandidates'] = 'end-of-candidates';
    mediaObject['iceOptions'] = 'renomination';
  }

  String get mid => mediaObject['mid'];

  bool get closed => mediaObject['port'] == 0;

  dynamic getObject() {
    return mediaObject;
  }

  void disable() {
    mediaObject['direction'] = 'inactive';
    mediaObject.remove('ext');
    mediaObject.remove('ssrcs');
    mediaObject.remove('ssrcGroups');
    mediaObject.remove('simulcast');
    mediaObject.remove('simulcast_03');
    mediaObject.remove('rids');
  }

  void close() {
    mediaObject['direction'] = 'inactive';
    mediaObject['port'] = 0;
    mediaObject.remove('ext');
    mediaObject.remove('ssrcs');
    mediaObject.remove('ssrcGroups');
    mediaObject.remove('simulcast');
    mediaObject.remove('simulcast_03');
    mediaObject.remove('rids');
    mediaObject.remove('ext');
    mediaObject.remove('extmapAllowMixed');
  }
}

class AnswerMediaSection extends MediaSection {
  AnswerMediaSection({
    IceParameters? iceParameters,
    List<IceCandidate>? iceCandidates,
    DtlsParameters? dtlsParameters,
    SctpParameters? sctpParameters,
    PlainRtpParameters? plainRtpParameters,
    bool? planB = false,
    dynamic? offerMediaObject,
    RtpParameters? offerRtpParameters,
    RtpParameters? answerRtpParameters,
    ProducerCodecOptions? codecOptions,
    bool? extmapAllowMixed,
  }) : super(
            iceParameters: iceParameters,
            planB: planB,
            iceCandidates: iceCandidates,
            dtlsParameters: dtlsParameters) {
    mediaObject['mid'] = offerMediaObject['mid'];
    mediaObject['type'] = offerMediaObject['type'];
    mediaObject['protocol'] = offerMediaObject['protocol'];

    if (plainRtpParameters == null) {
      mediaObject['connection'] = {'ip': '127.0.0.1', 'version': 4};
      mediaObject['port'] = 7;
    } else {
      mediaObject['connection'] = {
        'ip': plainRtpParameters.ip,
        'version': plainRtpParameters.ipVersion
      };
      mediaObject['port'] = plainRtpParameters.port;
    }

    switch (offerMediaObject['type']) {
      case 'audio':
      case 'video':
        {
          mediaObject['direction'] = 'recvonly';
          mediaObject['rtp'] = [];
          mediaObject['rtcpFb'] = [];
          mediaObject['fmtp'] = [];

          for (var codec in answerRtpParameters!.codecs) {
            dynamic rtp = {
              'payload': codec.payloadType,
              'codec': getCodecName(codec),
              'rate': codec.clockRate
            };

            if (codec.channels! > 1) rtp.encoding = codec.channels;

            mediaObject['rtp'].add(rtp);

            Map<String, dynamic> codecParameters =
                json.decode(json.encode(codec.parameters ?? {}));

            if (codecOptions != null) {
              final offerCodec = offerRtpParameters!.codecs.firstWhere(
                  (item) => (item.payloadType == codec.payloadType));

              switch (codec.mimeType.toLowerCase()) {
                case 'audio/opus':
                  {
                    if (codecOptions.opusStereo != null) {
                      offerCodec.parameters['sprop-stereo'] =
                          codecOptions.opusStereo == true ? 1 : 0;
                      codecParameters['stereo'] =
                          codecOptions.opusStereo == true ? 1 : 0;
                    }

                    if (codecOptions.opusFec != null) {
                      offerCodec.parameters['useinbandfec'] =
                          codecOptions.opusFec == true ? 1 : 0;
                      codecParameters['useinbandfec'] =
                          codecOptions.opusFec == true ? 1 : 0;
                    }

                    if (codecOptions.opusDtx != null) {
                      offerCodec.parameters['usedtx'] =
                          codecOptions.opusDtx == true ? 1 : 0;
                      codecParameters['useinbandfec'] =
                          codecOptions.opusDtx == true ? 1 : 0;
                    }

                    if (codecOptions.opusMaxPlaybackRate != null) {
                      codecParameters['maxplaybackrate'] =
                          codecOptions.opusMaxPlaybackRate;
                    }

                    if (codecOptions.opusMaxAverageBitrate != null) {
                      codecParameters['maxaveragebitrate'] =
                          codecOptions.opusMaxAverageBitrate;
                    }

                    if (codecOptions.opusPtime != null) {
                      offerCodec.parameters.ptime = codecOptions.opusPtime;
                      codecParameters['ptime'] = codecOptions.opusPtime;
                    }

                    break;
                  }
                case 'video/vp8':
                case 'video/vp9':
                case 'video/h264':
                case 'video/h265':
                  {
                    if (codecOptions.videoGoogleStartBitrate != null) {
                      codecParameters['x-google-start-bitrate'] =
                          codecOptions.videoGoogleStartBitrate;
                    }

                    if (codecOptions.videoGoogleMaxBitrate != null) {
                      codecParameters['x-google-max-bitrate'] =
                          codecOptions.videoGoogleMaxBitrate;
                    }

                    if (codecOptions.videoGoogleMinBitrate != null) {
                      codecParameters['x-google-min-bitrate'] =
                          codecOptions.videoGoogleMinBitrate;
                    }
                  }
                  break;
              }
            }

            final fmtp = {'payload': codec.payloadType, 'config': ''};
            for (final key in codecParameters.keys) {
              if ((fmtp['config'] as String).isNotEmpty)
                fmtp['config'] = fmtp['config'] ?? '' ';';
            }

            if ((fmtp['config'] as String).isNotEmpty) {
              mediaObject['fmtp'].add(fmtp);
            }

            for (final fb in codec.rtcpFeedback!) {
              mediaObject['rtcpFb'].add({
                'payload': codec.payloadType,
                'type': fb.type,
                'subtype': fb.parameter
              });
            }
          }

          mediaObject['payloads'] = answerRtpParameters.codecs
              .map((codec) => codec.payloadType)
              .join(' ');

          mediaObject['ext'] = [];

          // TODO: Line 323 MediaSection.ts
        }
    }
  }

  @override
  void setDtlsRole(DtlsRole role) {
    // TODO: implement setDtlsRole
  }
}

class AnswerMediaSection1 extends MediaSection {
  AnswerMediaSection1(
      {required String mid,
      required MediaKind kind,
      IceParameters? iceParameters,
      List<IceCandidate>? iceCandidates,
      DtlsParameters? dtlsParameters,
      SctpParameters? sctpParameters,
      PlainRtpParameters? plainRtpParameters,
      dynamic? offerMediaObject,
      RtpParameters? offerRtpParameters,
      RtpParameters? answerRtpParameters,
      ProducerCodecOptions? codecOptions,
      bool? extmapAllowMixed,
      bool? planB = false,
      String? streamId,
      String? trackId,
      bool? oldDataChannelSpec})
      : super(
            iceParameters: iceParameters,
            planB: planB,
            iceCandidates: iceCandidates,
            dtlsParameters: dtlsParameters) {
    mediaObject['mid'] = offerMediaObject['mid'];
    mediaObject['type'] = offerMediaObject['type'];
    mediaObject['protocol'] = offerMediaObject['protocol'];

    if (plainRtpParameters == null) {
      mediaObject['connection'] = {'ip': '127.0.0.1', 'version': 4};
      mediaObject['port'] = 7;
    } else {
      mediaObject['connection'] = {
        'ip': plainRtpParameters.ip,
        'version': plainRtpParameters.ipVersion
      };
      mediaObject['port'] = plainRtpParameters.port;
    }

    switch (offerMediaObject['type']) {
      case 'audio':
      case 'video':
        {
          mediaObject['direction'] = 'recvonly';
          mediaObject['rtp'] = [];
          mediaObject['rtcpFb'] = [];
          mediaObject['fmtp'] = [];

          for (var codec in answerRtpParameters!.codecs) {
            dynamic rtp = {
              'payload': codec.payloadType,
              'codec': getCodecName(codec),
              'rate': codec.clockRate
            };

            if (codec.channels! > 1) rtp.encoding = codec.channels;

            mediaObject['rtp'].add(rtp);

            dynamic fmtp = {'payload': codec.payloadType, 'config': ''};

            for (var key in mediaObject.keys) {
              if (fmtp['config']) {
                fmtp['config'] += ';';
              }
              fmtp['config'] += '$key=${codec.parameters[key]}';
            }

            if (fmtp['config'] != null) {
              mediaObject['fmtp'].add(fmtp);
            }

            for (var fb in codec.rtcpFeedback!) {
              mediaObject['rtcpFb'].add({
                'payload': codec.payloadType,
                'type': fb.type,
                'subtype': fb.parameter
              });
            }
          }

          mediaObject['payloads'] = offerRtpParameters!.codecs
              .map((codec) => codec.payloadType)
              .join(' ');

          mediaObject['ext'] = [];

          for (var ext in offerRtpParameters.headerExtensions!) {
            mediaObject['ext'].push({'uri': ext.uri, 'value': ext.id});
          }

          mediaObject['rtcpMux'] = 'rtcp-mux';
          mediaObject['rtcpRsize'] = 'rtcp-rsize';

          final encoding = offerRtpParameters.encodings![0];
          final ssrc = encoding.ssrc;
          final rtxSsrc = (encoding.rtx != null && encoding.rtx?.ssrc != null)
              ? encoding.rtx!.ssrc
              : null;

          mediaObject['ssrcs'] = [];
          mediaObject['ssrcGroups'] = [];

          if (offerRtpParameters.rtcp?.cname != null) {
            mediaObject['ssrcs'].add({
              'id': ssrc,
              'attribute': 'cname',
              'value': offerRtpParameters.rtcp!.cname
            });
          }

          if (planB == true) {
            mediaObject['ssrcs'].add({
              'id': ssrc,
              'attribute': 'msid',
              'value': "${streamId ?? '-'} $trackId"
            });
          }

          if (rtxSsrc != null) {
            if (offerRtpParameters.rtcp?.cname != null) {
              mediaObject['ssrcs'].add({
                'id': rtxSsrc,
                'attribute': 'cname',
                'value': offerRtpParameters.rtcp!.cname
              });
            }

            if (planB == true) {
              mediaObject['ssrcs'].add({
                'id': rtxSsrc,
                'attribute': 'msid',
                'value': "${streamId ?? '-'} $trackId"
              });
            }

            mediaObject['ssrcGroups']
                .add({'semantics': 'FID', 'ssrcs': '$ssrc $rtxSsrc'});
          }
          break;
        }
      case 'application':
        {
          // TODO
        }
    }
  }

  @override
  void setDtlsRole(DtlsRole role) {
    mediaObject['setup'] = 'actpass';
  }

  void planBReceive(
      {required RtpParameters offerRtpParameters,
      required String streamId,
      required String trackId}) {
    final encoding = offerRtpParameters.encodings![0];
    final ssrc = encoding.ssrc;
    final rtxSsrc = (encoding.rtx != null && encoding.rtx?.ssrc != null)
        ? encoding.rtx!.ssrc
        : null;

    if (offerRtpParameters.rtcp?.cname != null) {
      mediaObject['ssrcs'].add({
        'id': ssrc,
        'attribute': 'cname',
        'value': offerRtpParameters.rtcp!.cname
      });
    }

    mediaObject['ssrcs'].add({
      'id': ssrc,
      'attribute': 'msid',
      'value': "${streamId ?? '-'} $trackId"
    });

    if (rtxSsrc != null) {
      if (offerRtpParameters.rtcp?.cname != null) {
        mediaObject['ssrcs'].add({
          'id': rtxSsrc,
          'attribute': 'cname',
          'value': offerRtpParameters.rtcp!.cname
        });
      }

      mediaObject['ssrcs'].add({
        'id': rtxSsrc,
        'attribute': 'msid',
        'value': "${streamId ?? '-'} $trackId"
      });

      /// Associate original and retransmission SSRCs.
      mediaObject['ssrcGroups']
          .add({'semantics': 'FID', 'ssrcs': '$ssrc $rtxSsrc'});
    }
  }

  void planBStopReceiving({required RtpParameters offerRtpParameters}) {
    final encoding = offerRtpParameters.encodings![0];
    final ssrc = encoding.ssrc;
    final rtxSsrc = (encoding.rtx != null && encoding.rtx?.ssrc != null)
        ? encoding.rtx!.ssrc
        : null;

    mediaObject['ssrcs'] = mediaObject['ssrcs']
        .where((item) => item['id'] != ssrc && item['id'] != rtxSsrc);

    if (rtxSsrc != null) {
      mediaObject['ssrcGroups'] = mediaObject['ssrcs']
          .where((item) => item['ssrcs'] != "${ssrc ?? '-'} $rtxSsrc");
    }
  }
}

getCodecName(RtpCodecParameters codec) {
  var valid = codec.mimeType.contains(RegExp(r'^(audio|video)'));
  var codecName = codec.mimeType.split('/')[1];

  if (!valid || codecName == null) throw Exception('invalid codec.mimeType');
  return codecName;
}
