// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rtp_parameters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RTCIceServer _$RTCIceServerFromJson(Map<String, dynamic> json) {
  return RTCIceServer(
    urls: (json['urls'] as List<dynamic>).map((e) => e as String).toList(),
    username: json['username'] as String?,
    credential: json['credential'] as String?,
    credentialType: json['credentialType'] as String,
  );
}

Map<String, dynamic> _$RTCIceServerToJson(RTCIceServer instance) =>
    <String, dynamic>{
      'urls': instance.urls,
      'username': instance.username,
      'credential': instance.credential,
      'credentialType': instance.credentialType,
    };

RtpCapabilities _$RtpCapabilitiesFromJson(Map<String, dynamic> json) {
  return RtpCapabilities(
    headerExtensions: (json['headerExtensions'] as List<dynamic>?)
        ?.map((e) => RtpHeaderExtension.fromJson(e as Map<String, dynamic>))
        .toList(),
    codecs: (json['codecs'] as List<dynamic>?)
        ?.map((e) => RtpCodecCapability.fromJson(e as Map<String, dynamic>))
        .toList(),
    fecMechanisms: (json['fecMechanisms'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
  );
}

Map<String, dynamic> _$RtpCapabilitiesToJson(RtpCapabilities instance) =>
    <String, dynamic>{
      'codecs': instance.codecs?.map((e) => e.toJson()).toList(),
      'headerExtensions':
          instance.headerExtensions?.map((e) => e.toJson()).toList(),
      'fecMechanisms': instance.fecMechanisms,
    };

RtcpFeedback _$RtcpFeedbackFromJson(Map<String, dynamic> json) {
  return RtcpFeedback(
    type: json['type'] as String,
    parameter: json['parameter'] as String?,
  );
}

Map<String, dynamic> _$RtcpFeedbackToJson(RtcpFeedback instance) =>
    <String, dynamic>{
      'type': instance.type,
      'parameter': instance.parameter,
    };

RtpCodecCapability _$RtpCodecCapabilityFromJson(Map<String, dynamic> json) {
  return RtpCodecCapability(
    kind: _$enumDecode(_$MediaKindEnumMap, json['kind']),
    mimeType: json['mimeType'] as String,
    clockRate: json['clockRate'] as int,
    preferredPayloadType: json['preferredPayloadType'] as int?,
    channels: json['channels'] as int?,
    parameters: json['parameters'] as Map<String, dynamic>?,
    rtcpFeedback: (json['rtcpFeedback'] as List<dynamic>?)
        ?.map((e) => RtcpFeedback.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$RtpCodecCapabilityToJson(RtpCodecCapability instance) =>
    <String, dynamic>{
      'kind': _$MediaKindEnumMap[instance.kind],
      'mimeType': instance.mimeType,
      'preferredPayloadType': instance.preferredPayloadType,
      'clockRate': instance.clockRate,
      'channels': instance.channels,
      'parameters': instance.parameters,
      'rtcpFeedback': instance.rtcpFeedback?.map((e) => e.toJson()).toList(),
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$MediaKindEnumMap = {
  MediaKind.audio: 'audio',
  MediaKind.video: 'video',
  MediaKind.application: 'application',
};

RtpHeaderExtension _$RtpHeaderExtensionFromJson(Map<String, dynamic> json) {
  return RtpHeaderExtension(
    preferredId: json['preferredId'] as int,
    uri: json['uri'] as String,
    kind: _$enumDecodeNullable(_$MediaKindEnumMap, json['kind']),
    preferredEncrypt: json['preferredEncrypt'] as bool?,
    direction: _$enumDecodeNullable(
        _$RtpHeaderExtensionDirectionEnumMap, json['direction']),
  );
}

Map<String, dynamic> _$RtpHeaderExtensionToJson(RtpHeaderExtension instance) =>
    <String, dynamic>{
      'kind': _$MediaKindEnumMap[instance.kind],
      'uri': instance.uri,
      'preferredId': instance.preferredId,
      'preferredEncrypt': instance.preferredEncrypt,
      'direction': _$RtpHeaderExtensionDirectionEnumMap[instance.direction],
    };

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$RtpHeaderExtensionDirectionEnumMap = {
  RtpHeaderExtensionDirection.sendrecv: 'sendrecv',
  RtpHeaderExtensionDirection.sendonly: 'sendonly',
  RtpHeaderExtensionDirection.recvonly: 'recvonly',
  RtpHeaderExtensionDirection.inactive: 'inactive',
};

RtpParameters _$RtpParametersFromJson(Map<String, dynamic> json) {
  return RtpParameters(
    codecs: (json['codecs'] as List<dynamic>)
        .map((e) => RtpCodecParameters.fromJson(e as Map<String, dynamic>))
        .toList(),
    headerExtensions: (json['headerExtensions'] as List<dynamic>?)
        ?.map((e) =>
            RtpHeaderExtensionParameters.fromJson(e as Map<String, dynamic>))
        .toList(),
    encodings: (json['encodings'] as List<dynamic>?)
        ?.map((e) => RtpEncodingParameters.fromJson(e as Map<String, dynamic>))
        .toList(),
    rtcp: json['rtcp'] == null
        ? null
        : RtcpParameters.fromJson(json['rtcp'] as Map<String, dynamic>),
  )..mid = json['mid'] as String?;
}

Map<String, dynamic> _$RtpParametersToJson(RtpParameters instance) =>
    <String, dynamic>{
      'mid': instance.mid,
      'codecs': instance.codecs.map((e) => e.toJson()).toList(),
      'headerExtensions':
          instance.headerExtensions?.map((e) => e.toJson()).toList(),
      'encodings': instance.encodings?.map((e) => e.toJson()).toList(),
      'rtcp': instance.rtcp?.toJson(),
    };

RtcpParameters _$RtcpParametersFromJson(Map<String, dynamic> json) {
  return RtcpParameters(
    cname: json['cname'] as String?,
    reducedSize: json['reducedSize'] as bool?,
    mux: json['mux'] as bool?,
  );
}

Map<String, dynamic> _$RtcpParametersToJson(RtcpParameters instance) =>
    <String, dynamic>{
      'cname': instance.cname,
      'reducedSize': instance.reducedSize,
      'mux': instance.mux,
    };

RtpEncodingParameters _$RtpEncodingParametersFromJson(
    Map<String, dynamic> json) {
  return RtpEncodingParameters(
    ssrc: json['ssrc'] as int?,
    rid: json['rid'] as String?,
    codecPayloadType: json['codecPayloadType'] as int?,
    rtx: json['rtx'] == null
        ? null
        : Rtx.fromJson(json['rtx'] as Map<String, dynamic>),
    dtx: json['dtx'] as bool?,
    scalabilityMode: json['scalabilityMode'] as String?,
    scaleResolutionDownBy: json['scaleResolutionDownBy'] as int?,
    maxBitrate: json['maxBitrate'] as int?,
    adaptivePtime: json['adaptivePtime'] as bool?,
    priority: _$enumDecodeNullable(_$PriorityEnumMap, json['priority']),
    networkPriority:
        _$enumDecodeNullable(_$PriorityEnumMap, json['networkPriority']),
  )..maxFramerate = json['maxFramerate'] as int?;
}

Map<String, dynamic> _$RtpEncodingParametersToJson(
        RtpEncodingParameters instance) =>
    <String, dynamic>{
      'ssrc': instance.ssrc,
      'rid': instance.rid,
      'codecPayloadType': instance.codecPayloadType,
      'rtx': instance.rtx?.toJson(),
      'dtx': instance.dtx,
      'scalabilityMode': instance.scalabilityMode,
      'scaleResolutionDownBy': instance.scaleResolutionDownBy,
      'maxBitrate': instance.maxBitrate,
      'maxFramerate': instance.maxFramerate,
      'adaptivePtime': instance.adaptivePtime,
      'priority': _$PriorityEnumMap[instance.priority],
      'networkPriority': _$PriorityEnumMap[instance.networkPriority],
    };

const _$PriorityEnumMap = {
  Priority.veryLow: 'veryLow',
  Priority.low: 'low',
  Priority.medium: 'medium',
  Priority.high: 'high',
};

Rtx _$RtxFromJson(Map<String, dynamic> json) {
  return Rtx(
    ssrc: json['ssrc'] as int,
  );
}

Map<String, dynamic> _$RtxToJson(Rtx instance) => <String, dynamic>{
      'ssrc': instance.ssrc,
    };

RtpHeaderExtensionParameters _$RtpHeaderExtensionParametersFromJson(
    Map<String, dynamic> json) {
  return RtpHeaderExtensionParameters(
    uri: json['uri'] as String,
    id: json['id'] as int,
    encrypt: json['encrypt'] as bool?,
    parameters: json['parameters'],
  );
}

Map<String, dynamic> _$RtpHeaderExtensionParametersToJson(
        RtpHeaderExtensionParameters instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'id': instance.id,
      'encrypt': instance.encrypt,
      'parameters': instance.parameters,
    };

RtpCodecParameters _$RtpCodecParametersFromJson(Map<String, dynamic> json) {
  return RtpCodecParameters(
    mimeType: json['mimeType'] as String,
    payloadType: json['payloadType'] as int,
    clockRate: json['clockRate'] as int,
    channels: json['channels'] as int?,
    parameters: json['parameters'],
    rtcpFeedback: (json['rtcpFeedback'] as List<dynamic>?)
        ?.map((e) => RtcpFeedback.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$RtpCodecParametersToJson(RtpCodecParameters instance) =>
    <String, dynamic>{
      'mimeType': instance.mimeType,
      'payloadType': instance.payloadType,
      'clockRate': instance.clockRate,
      'channels': instance.channels,
      'parameters': instance.parameters,
      'rtcpFeedback': instance.rtcpFeedback?.map((e) => e.toJson()).toList(),
    };
