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

enum TransportDirection {
  send,
  recv,
}

enum Protocol { udp, tcp }

enum IceCandidateType { host, srflx, prflx, relay }

enum TcpType { active, passive, so }

class IceCandidate {
  /*
	 * Unique identifier that allows ICE to correlate candidates that appear on
	 * multiple transports.
	 */
  final String foundation;

  /*
	 * The assigned priority of the candidate.
	 */
  final int priority;

  /*
	 * The IP address of the candidate.
	 */
  final String ip;

  /*
	 * The protocol of the candidate.
	 */
  final Protocol protocol;

  /*
	 * The port for the candidate.
	 */
  final int port;

  /*
	 * The type of candidate..
	 */
  late final IceCandidateType type;

  /*
	 * The type of TCP candidate.
	 */
  final TcpType? tcpType;

  IceCandidate({required this.foundation,
    required this.priority,
    required this.ip,
    required this.protocol,
    required this.port,
    required this.type,
    this.tcpType});

  static IceCandidate fromDynamic(data) {
    return IceCandidate(
        foundation: data['foundation'],
        priority: data['priority'],
        ip: data['ip'],
        protocol: Protocol.values
            .firstWhere((e) => e.toString() == 'Protocol.${data['protocol']}'),
        port: data['port'],
        type: IceCandidateType.values.firstWhere(
                (e) => e.toString() == 'IceCandidateType.${data['type']}'),
        tcpType: data['tcpType'] != null ? TcpType.values.firstWhere((e) =>
        e.toString() == 'TcpType.${data['tcpType']}') : null)
  }
}

/*
 * The hash function algorithm (as defined in the "Hash function Textual Names"
 * registry initially specified in RFC 4572 Section 8) and its corresponding
 * certificate fingerprint value (in lowercase hex string as expressed utilizing
 * the syntax of "fingerprint" in RFC 4572 Section 5).
 */
class DtlsFingerprint {
  late final String algorithm;
  late final String value;

  DtlsFingerprint({required this.algorithm, required this.value});

  static DtlsFingerprint fromDynamic(data) {
    return DtlsFingerprint(
      algorithm: data['algorithm'],
      value: data['value'],
    );
  }
}

enum DtlsRole { auto, client, server }

enum ConnectionState { new_, connecting, connected, failed, closed }

class DtlsParameters {
  /*
	 * DTLS fingerprints.
	 */
  final List<DtlsFingerprint> fingerprints;

  /*
	 * DTLS role. Default 'auto'.
	 */
  DtlsRole? role;

  DtlsParameters({required this.fingerprints, this.role});

  static DtlsParameters fromDynamic(data) {
    return DtlsParameters(
      fingerprints: data['fingerprints']
          .map<DtlsFingerprint>(DtlsFingerprint.fromDynamic)
          .toList(),
      role: DtlsRole.values
          .firstWhere((e) => e.toString() == 'DtlsRole.${data['role']}'),
    );
  }
}

class PlainRtpParameters {
  late final String ip;
  late final int ipVersion; // - 4 or 6.
  late final int port;

  PlainRtpParameters(
      {required this.ip, required this.ipVersion, required this.port});

  static PlainRtpParameters fromDynamic(data) {
    return PlainRtpParameters(
        ip: data['ip'], ipVersion: data['ipVersion'], port: data['port']);
  }
}

class Transport extends EventEmitter {
  /// Id.
  late String _id;

  /// Closed flag.
  bool closed = false;

  /// Direction.
  late TransportDirection direction;
  dynamic _extendedRtpCapabilities;
  late Map<String, bool> _canProduceByKind;
  int? _maxSctpMessageSize;
}
