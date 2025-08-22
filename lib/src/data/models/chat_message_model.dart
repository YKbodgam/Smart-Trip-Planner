import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/chat_message.dart';

part 'chat_message_model.g.dart';

@JsonSerializable()
@collection
class ChatMessageModel extends Equatable {
  Id id = Isar.autoIncrement; // ✅ mutable, Isar requires non-final

  @JsonKey(name: 'itineraryId')
  @Index()
  int? itineraryId;

  @JsonKey(name: 'content')
  late String content;

  @JsonKey(name: 'isUser')
  late bool isUser;

  @JsonKey(name: 'timestamp')
  late DateTime timestamp;

  @JsonKey(name: 'messageType')
  @Enumerated(EnumType.name)
  late MessageType messageType;

  @JsonKey(name: 'metadata')
  MessageMetadataModel? metadata;

  ChatMessageModel({
    this.id = Isar.autoIncrement,
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

  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id ?? Isar.autoIncrement,
      itineraryId: entity.itineraryId,
      content: entity.content,
      isUser: entity.isUser,
      timestamp: entity.timestamp,
      messageType: entity.messageType,
      metadata: entity.metadata != null
          ? MessageMetadataModel.fromEntity(entity.metadata!)
          : null,
    );
  }

  ChatMessage toEntity() {
    return ChatMessage(
      id: id == Isar.autoIncrement ? null : id,
      itineraryId: itineraryId,
      content: content,
      isUser: isUser,
      timestamp: timestamp,
      messageType: messageType,
      metadata: metadata?.toEntity(),
    );
  }

  ChatMessageModel copyWith({
    Id? id,
    int? itineraryId,
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

  @ignore // 👈 prevents Isar from trying to store this
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
@embedded // ✅ lowercase
class MessageMetadataModel extends Equatable {
  @JsonKey(name: 'tokensUsed')
  int? tokensUsed;

  @JsonKey(name: 'cost')
  double? cost;

  @JsonKey(name: 'processingTime')
  int? processingTime;

  @JsonKey(name: 'model')
  String? model;

  @JsonKey(name: 'error')
  String? error;

  MessageMetadataModel({
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

  @ignore // 👈 prevents Isar from trying to store this
  @override
  List<Object?> get props => [tokensUsed, cost, processingTime, model, error];
}
