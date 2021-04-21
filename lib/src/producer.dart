import 'package:eventify/eventify.dart';
import 'package:flutter_mediasoup_client/src/rtp_parameters.dart';
import 'package:flutter_mediasoup_client/src/errors.dart';
import 'package:flutter_mediasoup_client/src/utils/enhanced_event_emitter.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ProducerCodecOptions {
  bool? opusStereo;
  bool? opusFec;
  bool? opusDtx;
  int? opusMaxPlaybackRate;
  int? opusMaxAverageBitrate;
  int? opusPtime;
  int? videoGoogleStartBitrate;
  int? videoGoogleMaxBitrate;
  int? videoGoogleMinBitrate;

  ProducerCodecOptions(
      {this.opusDtx,
      this.opusFec,
      this.opusMaxAverageBitrate,
      this.opusMaxPlaybackRate,
      this.opusPtime,
      this.opusStereo,
      this.videoGoogleMaxBitrate,
      this.videoGoogleMinBitrate,
      this.videoGoogleStartBitrate});
}

class Producer extends EventEmitter {
  late final String _id;
  late final String _localId;
  bool _closed = false;
  RTCRtpSender? _rtpSender;
  MediaStreamTrack? _track;
  late final MediaKind _kind;
  late final RtpParameters _rtpParameters;
  late final bool _paused;
  int? _maxSpatialLayer;
  late final bool _stopTracks;
  late final bool _disableTrackOnPause;
  late final bool _zeroRtpOnPause;
  dynamic? _appData;
  final _observer = EnhancedEventEmitter();

  Producer({
    required String id,
    required String localId,
    required MediaStreamTrack track,
    required RtpParameters rtpParameters,
    required bool stopTracks,
    required bool disableTrackOnPause,
    required bool zeroRtpOnPause,
    dynamic? appData,
    RTCRtpSender? rtpSender,
  }) : super() {
    _id = id;
    _localId = localId;
    _rtpSender = rtpSender;
    _track = track;
    _kind = track.kind as MediaKind;
    _rtpParameters = rtpParameters;
    _paused = disableTrackOnPause ? !track.enabled : false;
    _stopTracks = stopTracks;
    _disableTrackOnPause = disableTrackOnPause;
    _zeroRtpOnPause = zeroRtpOnPause;
    _appData = appData;

    _handleTrack();
  }

  String get id => _id;

  String get localId => _localId;

  bool get closed => _closed;

  MediaKind get kind => _kind;

  RTCRtpSender? get rtpSender => _rtpSender;

  MediaStreamTrack? get track => _track;

  RtpParameters get rtpParameters => _rtpParameters;

  bool get paused => _paused;

  int? get maxSpatialLayer => _maxSpatialLayer;

  dynamic? get appData => _appData;

  EnhancedEventEmitter get observer => _observer;

  void close() {
    if (_closed) {
      return;
    }

    _closed = true;

    _destroyTrack();

    emit('@close');

    _observer.safeEmit('close');
  }

  void transportClosed() {
    if (_closed) {
      return;
    }

    _closed = true;
    _destroyTrack();
    emit('transportclose');

    _observer.safeEmit('close');
  }

  getStats() {
    emit('@getstats');
  }

  void pause() {
    if (_closed) {
      return;
    }

    _paused = true;

    if (_track != null && _disableTrackOnPause) {
      _track?.enabled = false;
    }

    if (_zeroRtpOnPause) {
      emit('@replacetrack', null);
    }

    _observer.emit('pause');
  }

  void resume() {
    if (_closed) {
      return;
    }

    _paused = false;

    if (_track != null && _disableTrackOnPause) {
      _track?.enabled = false;
    }

    if (_zeroRtpOnPause) {
      emit('@replacetrack', _track);
    }

    _observer.emit('resume');
  }

  /// Replaces the current track with a new one or null.
  Future<void> replaceTrack({MediaStreamTrack? track}) async {
    if (_closed) {
      if (track != null && _stopTracks) {
        await track.stop();
      }
      throw InvalidStateError('closed');
    } else if (track != null && !track.enabled) {
      throw InvalidStateError('track ended');
    }

    if (track == _track) {
      return;
    }

    if (!_zeroRtpOnPause || !_paused) {
      emit('@replacetrack', track);
    }

    // Destroy the previous track.
    _destroyTrack();

    // Set the new track.
    _track = track;

    // If this Producer was paused/resumed and the state of the new
    // track does not match, fix it.
    if (_disableTrackOnPause) {
      if (!_paused)
        _track?.enabled = true;
      else if (_paused) _track?.enabled = false;
    }
    _handleTrack();
  }

  Future<void> setMaxSpatialLayer(int spatialLayer) async {
    if (_closed) throw InvalidStateError('closed');
    if (_kind != MediaKind.video)
      throw UnsupportedError('not a video Producer');

    if (spatialLayer == _maxSpatialLayer) return;

    emit('@setmaxspatiallayer', spatialLayer);
    _maxSpatialLayer = spatialLayer;
  }

  /// Sets the DSCP value.
  Future<void> setRtpEncodingParameters(RtpEncodingParameters params) async {
    if (_closed) {
      throw InvalidStateError('closed');
    }

    emit('@setrtpencodingparameters', params);
  }

  void _handleTrack() {
    if (_track == null) {
      return;
    }

    _track?.onEnded = _onTrackEnded;
  }

  _onTrackEnded() {
    emit('trackended');

    _observer.safeEmit('trackended');
  }

  void _destroyTrack() {
    if (_track == null) {
      return;
    }

    _track?.onEnded = null;

    if (_stopTracks) {
      _track?.stop();
    }
  }
}
