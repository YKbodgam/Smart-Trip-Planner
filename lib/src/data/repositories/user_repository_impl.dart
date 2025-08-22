import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';

import '../../core/config/app_config.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final Isar _isar;

  UserRepositoryImpl({Isar? isar}) : _isar = isar ?? AppConfig.isar;

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModels = await _isar.userModels.where().findAll();
      if (userModels.isEmpty) {
        return const Right(null);
      }
      return Right(userModels.first.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> saveUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _isar.writeTxn(() async {
        await _isar.userModels.put(userModel);
      });
      return Right(userModel.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(User user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      final userModel = UserModel.fromEntity(updatedUser);
      await _isar.writeTxn(() async {
        await _isar.userModels.put(userModel);
      });
      return Right(userModel.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String uid) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.userModels.where().uidEqualTo(uid).deleteAll();
      });
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateTokenUsage({
    required String uid,
    required int requestTokens,
    required int responseTokens,
    required double cost,
  }) async {
    try {
      final existingUser = await _isar.userModels
          .where()
          .uidEqualTo(uid)
          .findFirst();
      if (existingUser == null) {
        return const Left(DatabaseFailure(message: 'User not found'));
      }

      final updatedUser = existingUser.copyWith(
        requestTokensUsed: existingUser.requestTokensUsed + requestTokens,
        responseTokensUsed: existingUser.responseTokensUsed + responseTokens,
        totalCost: existingUser.totalCost + cost,
        updatedAt: DateTime.now(),
      );

      await _isar.writeTxn(() async {
        await _isar.userModels.put(updatedUser);
      });

      return Right(updatedUser.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearUserData() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.userModels.clear();
      });
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
