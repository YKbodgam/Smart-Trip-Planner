import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(int? itineraryId);
  Future<Either<Failure, ChatMessage>> saveMessage(ChatMessage message);
  Future<Either<Failure, void>> deleteMessage(int messageId);
  Future<Either<Failure, void>> clearChatHistory(int? itineraryId);
  Future<Either<Failure, void>> clearAllChatHistory();
  Stream<ChatMessage> watchMessages(int? itineraryId);
}
