import 'dart:core';
import 'package:eventify/eventify.dart';
import 'package:flutter_mediasoup_client/src/rtp_parameters.dart';
import 'package:flutter_mediasoup_client/src/utils/enhanced_event_emitter.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'errors.dart';

class ConsumerOptions {
  String? id;
  String? producerId;
  MediaKind? kind;
  RtpParameters? rtpParameters;
  dynamic? appData;
}

class Consumer extends EventEmitter {
  late final String _id;
  late final String _localId;
  late final String _producerId;
  late MediaStreamTrack _track;

  bool _closed = false;
  late bool _paused;

  RtpParameters? _rtpParameters;
  RTCRtpReceiver? _rtpReceiver;

  dynamic? _appData;

  final EnhancedEventEmitter _observer = EnhancedEventEmitter();

  Consumer(
      {required String id,
      required String localId,
      required String producerId,
      required MediaStreamTrack track,
      RTCRtpReceiver? rtpReceiver,
      dynamic? appData,
      RtpParameters? rtpParameters})
      : super() {
    _id = id;
    _localId = localId;
    _producerId = producerId;
    _track = track;
    _rtpReceiver = rtpReceiver;
    _rtpParameters = rtpParameters;
    _paused = !track.enabled;
    _appData = appData;

    _handleTrack();
  }

  String get id => _id;

  String get localId => _localId;

  String get producerId => _producerId;

  bool get closed => _closed;

  bool get paused => _paused;

  MediaStreamTrack get track => _track;

  RtpParameters? get rtpParameters => _rtpParameters;

  RTCRtpReceiver? get rtpReceiver => _rtpReceiver;

  dynamic? get appData => _appData;

  EnhancedEventEmitter get observer => _observer;

  /// Transport was closed.
  void transportClosed() {
    if (_closed) {
      return;
    }

    _closed = true;
    _destroyTrack();

    emit('transportclose');
    _observer.safeEmit('close');
  }

  /// Get associated RTCRtpReceiver stats.
  void getStats() async {
    if (_closed) {
      throw InvalidStateError('closed');
    }
    emit('@getstats');
  }

  /// Pauses receiving media
  void pause() {
    if (_closed) {
      return;
    }

    _paused = true;
    _track.enabled = false;

    _observer.safeEmit('pause');
  }

  /// Resumes receiving media.
  void resume() {
    if (_closed) {
      return;
    }

    _paused = false;
    _track.enabled = true;

    emit('resume');
  }

  /// Closes the Consumer.
  void close() {
    if (_closed) return;

    _closed = true;
    _destroyTrack();
    emit('@close');
    _observer.safeEmit('close');
  }

  _onTrackEnded() {
    emit('trackEnded');
    _observer.safeEmit('trackEnded');
  }

  void _handleTrack() {
    _track.onEnded = _onTrackEnded();
  }

  _destroyTrack() {
    _track.stop();
  }
}
