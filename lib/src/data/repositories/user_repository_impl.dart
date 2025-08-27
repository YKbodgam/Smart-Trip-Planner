import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/database/hive_service.dart';
import '../../core/database/firestore_service.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final HiveService _hiveService;
  final FirestoreService _firestoreService;
  final Connectivity _connectivity;

  UserRepositoryImpl({
    HiveService? hiveService,
    FirestoreService? firestoreService,
    Connectivity? connectivity,
  }) : _hiveService = hiveService ?? HiveService.instance,
       _firestoreService = firestoreService ?? FirestoreService.instance,
       _connectivity = connectivity ?? Connectivity();

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // First try to get from local storage
      final localUser = await _getLocalUser();
      if (localUser == null) {
        return const Right(null);
      }

      // If online, sync with cloud and return latest
      if (await _isOnline()) {
        final cloudUser = await _firestoreService.getUser(localUser.uid);
        if (cloudUser != null) {
          // Update local storage with cloud data
          await _hiveService.usersBox.put(cloudUser.uid, cloudUser);
          return Right(cloudUser.toEntity());
        }
      }

      return Right(localUser.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<UserModel?> _getLocalUser() async {
    final userModels = _hiveService.usersBox.values.toList();
    if (userModels.isEmpty) return null;
    return userModels.first;
  }

  Future<bool> _isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Future<Either<Failure, User>> saveUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);

      // Save locally
      await _hiveService.usersBox.put(userModel.uid, userModel);

      // If online, save to cloud
      if (await _isOnline()) {
        await _firestoreService.saveUser(userModel);
      }

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

      // Update locally
      await _hiveService.usersBox.put(userModel.uid, userModel);

      // If online, update cloud
      if (await _isOnline()) {
        await _firestoreService.updateUser(userModel);
      }

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
      // Delete locally
      await _hiveService.usersBox.delete(uid);

      // If online, delete from cloud
      if (await _isOnline()) {
        await _firestoreService.deleteUser(uid);
      }

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
      final existingUser = await _getLocalUser();
      if (existingUser == null) {
        return Left(DatabaseFailure(message: 'User not found'));
      }

      final updatedUser = existingUser.copyWith(
        requestTokensUsed: existingUser.requestTokensUsed + requestTokens,
        responseTokensUsed: existingUser.responseTokensUsed + responseTokens,
        totalCost: existingUser.totalCost + cost,
        updatedAt: DateTime.now(),
      );

      // Update locally
      await _hiveService.usersBox.put(uid, updatedUser);

      // If online, update cloud
      if (await _isOnline()) {
        await _firestoreService.updateUser(updatedUser);
      }

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
      await _hiveService.usersBox.clear();
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
