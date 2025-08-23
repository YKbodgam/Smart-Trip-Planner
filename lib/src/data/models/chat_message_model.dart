import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_message.dart' as domain;

part 'chat_message_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 5)
class ChatMessageModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  @JsonKey(name: 'itineraryId')
  final String? itineraryId;

  @HiveField(2)
  @JsonKey(name: 'content')
  final String content;

  @HiveField(3)
  @JsonKey(name: 'isUser')
  final bool isUser;

  @HiveField(4)
  @JsonKey(name: 'timestamp')
  final DateTime timestamp;

  @HiveField(5)
  @JsonKey(name: 'messageType')
  final MessageType messageType;

  @HiveField(6)
  @JsonKey(name: 'metadata')
  final MessageMetadataModel? metadata;

  const ChatMessageModel({
    required this.id,
    this.itineraryId,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.messageType = MessageType.text,
    this.metadata,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

  // ✅ Convert from domain entity
  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      itineraryId: entity.itineraryId,
      content: entity.content,
      isUser: entity.isUser,
      timestamp: entity.timestamp,
      messageType: _mapDomainMessageType(entity.messageType),
      metadata: entity.metadata != null
          ? MessageMetadataModel.fromEntity(entity.metadata!)
          : null,
    );
  }

  static MessageType _mapDomainMessageType(dynamic domainType) {
    if (domainType == null) return MessageType.text;
    return MessageType.values.firstWhere(
      (e) => e.name == domainType.toString().split('.').last,
      orElse: () => MessageType.text,
    );
  }

  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      itineraryId: itineraryId,
      content: content,
      isUser: isUser,
      timestamp: timestamp,
      messageType: _mapModelMessageTypeToDomain(messageType),
      metadata: metadata?.toEntity(),
    );
  }

  static domain.MessageType _mapModelMessageTypeToDomain(
    MessageType modelType,
  ) {
    switch (modelType) {
      case MessageType.text:
        return domain.MessageType.text;
      case MessageType.itinerary:
        return domain.MessageType.itinerary;
      case MessageType.error:
        return domain.MessageType.error;
      case MessageType.loading:
        return domain.MessageType.loading;
    }
  }

  ChatMessageModel copyWith({
    String? id,
    String? itineraryId,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageType? messageType,
    MessageMetadataModel? metadata,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      itineraryId: itineraryId ?? this.itineraryId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    itineraryId,
    content,
    isUser,
    timestamp,
    messageType,
    metadata,
  ];
}

@JsonSerializable()
@HiveType(typeId: 6)
class MessageMetadataModel extends Equatable {
  @HiveField(0)
  @JsonKey(name: 'tokensUsed')
  final int? tokensUsed;

  @HiveField(1)
  @JsonKey(name: 'cost')
  final double? cost;

  @HiveField(2)
  @JsonKey(name: 'processingTime')
  final int? processingTime;

  @HiveField(3)
  @JsonKey(name: 'model')
  final String? model;

  @HiveField(4)
  @JsonKey(name: 'error')
  final String? error;

  const MessageMetadataModel({
    this.tokensUsed,
    this.cost,
    this.processingTime,
    this.model,
    this.error,
  });

  factory MessageMetadataModel.fromJson(Map<String, dynamic> json) =>
      _$MessageMetadataModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageMetadataModelToJson(this);

  factory MessageMetadataModel.fromEntity(MessageMetadata entity) {
    return MessageMetadataModel(
      tokensUsed: entity.tokensUsed,
      cost: entity.cost,
      processingTime: entity.processingTime,
      model: entity.model,
      error: entity.error,
    );
  }

  MessageMetadata toEntity() {
    return MessageMetadata(
      tokensUsed: tokensUsed,
      cost: cost,
      processingTime: processingTime,
      model: model,
      error: error,
    );
  }

  @override
  List<Object?> get props => [tokensUsed, cost, processingTime, model, error];
}

@HiveType(typeId: 7)
@JsonEnum(alwaysCreate: true) // ✅ ensures json_serializable generates mapping
enum MessageType {
  @HiveField(0)
  text,

  @HiveField(1)
  itinerary,

  @HiveField(2)
  error,

  @HiveField(3)
  loading,
}
