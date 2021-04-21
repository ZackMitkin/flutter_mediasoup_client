class NumSctpStreams {
  /// Initially requested number of outgoing SCTP streams.
  late final int os;

  /// Maximum number of incoming SCTP streams.
  late final int mis;

  NumSctpStreams({required this.os, required this.mis});

  static NumSctpStreams fromDynamic(dynamic data) {
    return NumSctpStreams(os: data['OS'], mis: data['MIS']);
  }
}

class SctpCapabilities {
  late final NumSctpStreams numStreams;

  SctpCapabilities({required this.numStreams});
}

class SctpParameters {
  /*
	 * Must always equal 5000.
	 */
  late final int port;

  /*
	 * Initially requested number of outgoing SCTP streams.
	 */
  late final int os;

  /*
	 * Maximum number of incoming SCTP streams.
	 */
  late final int mis;

  /*
	 * Maximum allowed size for SCTP messages.
	 */
  late final int maxMessageSize;

  SctpParameters(
      {required this.port,
      required this.os,
      required this.mis,
      required this.maxMessageSize});

  static SctpParameters fromDynamic(dynamic data) {
    return SctpParameters(
      port: data['port'],
      os: data['OS'],
      mis: data['MIS'],
      maxMessageSize: data['maxMessageSize'],
    );
  }
}
