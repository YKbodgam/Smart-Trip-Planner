import 'package:equatable/equatable.dart';

enum MessageType {
  text,
  itinerary,
  error,
  loading,
  system,
}

class ChatMessage extends Equatable {
  final int? id;
  final int? itineraryId;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType messageType;
  final MessageMetadata? metadata;

  const ChatMessage({
    this.id,
    this.itineraryId,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.messageType = MessageType.text,
    this.metadata,
  });

  ChatMessage copyWith({
    int? id,
    int? itineraryId,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageType? messageType,
    MessageMetadata? metadata,
  }) {
    return ChatMessage(
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

class MessageMetadata extends Equatable {
  final int? tokensUsed;
  final double? cost;
  final int? processingTime;
  final String? model;
  final String? error;

  const MessageMetadata({
    this.tokensUsed,
    this.cost,
    this.processingTime,
    this.model,
    this.error,
  });

  MessageMetadata copyWith({
    int? tokensUsed,
    double? cost,
    int? processingTime,
    String? model,
    String? error,
  }) {
    return MessageMetadata(
      tokensUsed: tokensUsed ?? this.tokensUsed,
      cost: cost ?? this.cost,
      processingTime: processingTime ?? this.processingTime,
      model: model ?? this.model,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        tokensUsed,
        cost,
        processingTime,
        model,
        error,
      ];
}
