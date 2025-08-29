import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, User?>> getUserByEmail(String email);
  Future<Either<Failure, User>> saveUser(User user);
  Future<Either<Failure, User>> updateUser(User user);
  Future<Either<Failure, void>> deleteUser(String uid);
  Future<Either<Failure, User>> updateTokenUsage({
    required String uid,
    required int requestTokens,
    required int responseTokens,
    required double cost,
  });
  Future<Either<Failure, void>> clearUserData();
}
