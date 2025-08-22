// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      id: (json['id'] as num?)?.toInt() ?? Isar.autoIncrement,
      itineraryId: (json['itineraryId'] as num?)?.toInt(),
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      messageType:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['messageType']) ??
              MessageType.text,
      metadata: json['metadata'] == null
          ? null
          : MessageMetadataModel.fromJson(
              json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatMessageModelToJson(ChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itineraryId': instance.itineraryId,
      'content': instance.content,
      'isUser': instance.isUser,
      'timestamp': instance.timestamp.toIso8601String(),
      'messageType': _$MessageTypeEnumMap[instance.messageType]!,
      'metadata': instance.metadata,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.itinerary: 'itinerary',
  MessageType.error: 'error',
  MessageType.loading: 'loading',
  MessageType.system: 'system',
};

MessageMetadataModel _$MessageMetadataModelFromJson(
        Map<String, dynamic> json) =>
    MessageMetadataModel(
      tokensUsed: (json['tokensUsed'] as num?)?.toInt(),
      cost: (json['cost'] as num?)?.toDouble(),
      processingTime: (json['processingTime'] as num?)?.toInt(),
      model: json['model'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$MessageMetadataModelToJson(
        MessageMetadataModel instance) =>
    <String, dynamic>{
      'tokensUsed': instance.tokensUsed,
      'cost': instance.cost,
      'processingTime': instance.processingTime,
      'model': instance.model,
      'error': instance.error,
    };
