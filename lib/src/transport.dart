import 'package:eventify/eventify.dart';

class IceParameters {
  /// ICE username fragment.
  late String usernameFragment;

  /// ICE password.
  late String password;

  /// ICE Lite.
  bool? iceLite;
}

class TransportOptions {
  late String id;
  late List<IceParameters> iceParameters;
}

enum Direction {
  send,
  recv,
}

class Transport extends EventEmitter {
  late String _id;
  bool closed = false;
  late Direction direction;
  dynamic _extendedRtpCapabilities;
  late Map<String, bool> _canProduceByKind;
  int? _maxSctpMessageSize;

}
