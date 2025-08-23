// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMessageModelAdapter extends TypeAdapter<ChatMessageModel> {
  @override
  final int typeId = 5;

  @override
  ChatMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessageModel(
      id: fields[0] as String,
      itineraryId: fields[1] as String?,
      content: fields[2] as String,
      isUser: fields[3] as bool,
      timestamp: fields[4] as DateTime,
      messageType: fields[5] as MessageType,
      metadata: fields[6] as MessageMetadataModel?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessageModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itineraryId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.isUser)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.messageType)
      ..writeByte(6)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageMetadataModelAdapter extends TypeAdapter<MessageMetadataModel> {
  @override
  final int typeId = 6;

  @override
  MessageMetadataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageMetadataModel(
      tokensUsed: fields[0] as int?,
      cost: fields[1] as double?,
      processingTime: fields[2] as int?,
      model: fields[3] as String?,
      error: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MessageMetadataModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.tokensUsed)
      ..writeByte(1)
      ..write(obj.cost)
      ..writeByte(2)
      ..write(obj.processingTime)
      ..writeByte(3)
      ..write(obj.model)
      ..writeByte(4)
      ..write(obj.error);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageMetadataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageTypeAdapter extends TypeAdapter<MessageType> {
  @override
  final int typeId = 7;

  @override
  MessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageType.text;
      case 1:
        return MessageType.itinerary;
      case 2:
        return MessageType.error;
      case 3:
        return MessageType.loading;
      default:
        return MessageType.text;
    }
  }

  @override
  void write(BinaryWriter writer, MessageType obj) {
    switch (obj) {
      case MessageType.text:
        writer.writeByte(0);
        break;
      case MessageType.itinerary:
        writer.writeByte(1);
        break;
      case MessageType.error:
        writer.writeByte(2);
        break;
      case MessageType.loading:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      id: json['id'] as String,
      itineraryId: json['itineraryId'] as String?,
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
