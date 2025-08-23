import 'package:dartz/dartz.dart';

import '../../core/database/hive_service.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final HiveService _hiveService;

  ChatRepositoryImpl({HiveService? hiveService})
    : _hiveService = hiveService ?? HiveService.instance;

  @override
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(
    String? itineraryId,
  ) async {
    try {
      final messageModels = _hiveService.chatMessagesBox.values.where((model) {
        if (itineraryId != null) {
          return model.itineraryId == itineraryId;
        }
        return model.itineraryId == null;
      }).toList();
      messageModels.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final messages = messageModels.map((model) => model.toEntity()).toList();
      return Right(messages);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> saveMessage(ChatMessage message) async {
    try {
      final messageModel = ChatMessageModel.fromEntity(message);
      await _hiveService.chatMessagesBox.put(messageModel.id, messageModel);
      return Right(messageModel.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(int messageId) async {
    try {
      await _hiveService.chatMessagesBox.delete(messageId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearChatHistory(String? itineraryId) async {
    try {
      final keysToDelete = _hiveService.chatMessagesBox.values
          .where(
            (model) => itineraryId != null
                ? model.itineraryId == itineraryId
                : model.itineraryId == null,
          )
          .map((model) => model.id)
          .toList();
      for (final key in keysToDelete) {
        await _hiveService.chatMessagesBox.delete(key);
      }
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllChatHistory() async {
    try {
      await _hiveService.chatMessagesBox.clear();
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<ChatMessage> watchMessages(int? itineraryId) async* {
    // Hive does not support native streams, so you may need to use a custom solution.
    // For now, this is a placeholder.
    throw UnimplementedError(
      'Hive does not support native streams. Use a ValueListenableBuilder or similar.',
    );
  }
}
