import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';

import '../../core/config/app_config.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Isar _isar;

  ChatRepositoryImpl({Isar? isar}) : _isar = isar ?? AppConfig.isar;

  @override
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(
    int? itineraryId,
  ) async {
    try {
      final query = itineraryId != null
          ? _isar.chatMessageModels.where().itineraryIdEqualTo(itineraryId)
          : _isar.chatMessageModels.where().itineraryIdIsNull();

      final messageModels = await query.sortByTimestamp().findAll();
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
      await _isar.writeTxn(() async {
        await _isar.chatMessageModels.put(messageModel);
      });
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
      await _isar.writeTxn(() async {
        await _isar.chatMessageModels.delete(messageId);
      });
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearChatHistory(int? itineraryId) async {
    try {
      await _isar.writeTxn(() async {
        if (itineraryId != null) {
          await _isar.chatMessageModels
              .where()
              .itineraryIdEqualTo(itineraryId)
              .deleteAll();
        } else {
          await _isar.chatMessageModels.where().itineraryIdIsNull().deleteAll();
        }
      });
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
      await _isar.writeTxn(() async {
        await _isar.chatMessageModels.clear();
      });
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<ChatMessage> watchMessages(int? itineraryId) {
    final query = itineraryId != null
        ? _isar.chatMessageModels.where().itineraryIdEqualTo(itineraryId)
        : _isar.chatMessageModels.where().itineraryIdIsNull();

    return query.watch(fireImmediately: true).map((models) {
      return models.map((model) => model.toEntity()).last;
    });
  }
}
