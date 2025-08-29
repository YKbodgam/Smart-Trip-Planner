import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../providers/repository_providers.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthNotifier(userRepository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final UserRepository _userRepository;
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool isInitialized = false;

  AuthNotifier(this._userRepository) : super(const AuthState.initial()) {
    _checkAuthState();
  }

  static Future<void> initSignIn() async {
    if (!isInitialized) {
      await _googleSignIn.initialize(
        serverClientId:
            '519361159906-kelffp1k11697n2h4v3of50rfqq8fkc9.apps.googleusercontent.com',
      );
    }

    isInitialized = true;
  }

  void _checkAuthState() {
    _firebaseAuth.authStateChanges().listen((firebaseUser) {
      debugPrint(
        '🔄 Firebase auth state changed: ${firebaseUser?.uid ?? 'null'}',
      );
      if (firebaseUser != null) {
        _loadUser(firebaseUser);
      } else {
        debugPrint('👋 User signed out, setting state to unauthenticated');
        state = const AuthState.unauthenticated();
      }
    });
  }

  Future<void> _loadUser(firebase_auth.User firebaseUser) async {
    debugPrint('🔄 Loading user from database: ${firebaseUser.uid}');
    state = const AuthState.loading();

    final result = await _userRepository.getCurrentUser();
    result.fold(
      (failure) {
        debugPrint('❌ Failed to get current user: ${failure.message}');
        state = AuthState.error(failure.message);
      },
      (user) {
        if (user != null) {
          debugPrint('✅ User loaded from database: ${user.uid}');
          state = AuthState.authenticated(user);
        } else {
          debugPrint(
            '🆕 User not found in database, creating new user: ${firebaseUser.uid}',
          );
          // Create new user
          _createUser(firebaseUser);
        }
      },
    );
  }

  Future<void> _createUser(firebase_auth.User firebaseUser) async {
    debugPrint('🆕 Creating new user in database: ${firebaseUser.uid}');
    final user = User(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _userRepository.saveUser(user);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to create user: ${failure.message}');
        state = AuthState.error(failure.message);
      },
      (savedUser) {
        debugPrint('✅ User created successfully: ${savedUser.uid}');
        state = AuthState.authenticated(savedUser);
      },
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    debugPrint('🔐 Attempting email sign in: $email');
    state = const AuthState.loading();

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint(
        '✅ Email sign in successful, user will be loaded via auth state listener',
      );
      // User will be loaded automatically via auth state listener
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase auth error: ${e.code} - ${e.message}');
      state = AuthState.error(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('❌ Unexpected error during email sign in: $e');
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    debugPrint('📝 Attempting email signup: $email');
    state = const AuthState.loading();

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('✅ Firebase user created: ${userCredential.user!.uid}');

      // Create user profile in database
      final user = User(
        uid: userCredential.user!.uid,
        email: email,
        displayName: null,
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _userRepository.saveUser(user);
      result.fold(
        (failure) {
          debugPrint('❌ Failed to save user to database: ${failure.message}');
          state = AuthState.error(failure.message);
        },
        (savedUser) {
          debugPrint('✅ User created successfully: ${savedUser.uid}');
          state = AuthState.authenticated(savedUser);
        },
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase auth error: ${e.code} - ${e.message}');
      state = AuthState.error(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('❌ Unexpected error during signup: $e');
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();

    try {
      await initSignIn();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      final authorizationClient = googleUser.authorizationClient;

      GoogleSignInClientAuthorization? authorization = await authorizationClient
          .authorizationForScopes(['email', 'profile']);

      final accessToken = authorization?.accessToken;

      if (accessToken == null) {
        final authorization2 = await authorizationClient.authorizationForScopes(
          ['email', 'profile'],
        );

        if (authorization2?.accessToken == null) {
          debugPrint('❌ Google sign in cancelled by user');
          state = const AuthState.unauthenticated();
          return;
        }

        authorization = authorization2;
      }

      // Check if user with this email already exists
      final existingUserResult = await _userRepository.getUserByEmail(
        googleUser.email,
      );
      final existingUser = existingUserResult.fold(
        (failure) => null,
        (user) => user,
      );

      if (existingUser != null) {
        debugPrint('✅ Existing user found with email: ${googleUser.email}');
        // User exists, just sign them in with Firebase
        final credential = firebase_auth.GoogleAuthProvider.credential(
          idToken: idToken,
          accessToken: accessToken,
        );

        await _firebaseAuth.signInWithCredential(credential);
        debugPrint('✅ Existing user signed in with Google');
        // User will be loaded automatically via auth state listener
      } else {
        debugPrint('🆕 No existing user found, creating new user');
        // Create new user with Firebase
        final credential = firebase_auth.GoogleAuthProvider.credential(
          idToken: idToken,
          accessToken: accessToken,
        );

        final firebase_auth.UserCredential userCredential = await _firebaseAuth
            .signInWithCredential(credential);

        debugPrint('✅ Google sign in successful: ${googleUser.email}');
        debugPrint('✅ Firebase user created: ${userCredential.user!.uid}');

        // Create new user in database
        final user = User(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = await _userRepository.saveUser(user);
        result.fold(
          (failure) {
            debugPrint(
              '❌ Failed to save Google user to database: ${failure.message}',
            );
            state = AuthState.error(failure.message);
          },
          (savedUser) {
            debugPrint('✅ Google user created successfully: ${savedUser.uid}');
            state = AuthState.authenticated(savedUser);
          },
        );
      }
    } catch (e) {
      debugPrint('❌ Google sign in error: $e');
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    debugPrint('👋 Signing out user');
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    state = const AuthState.unauthenticated();
  }

  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    final result = await _userRepository.getCurrentUser();
    return result.fold((failure) => null, (user) => user);
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An authentication error occurred.';
    }
  }
}

class AuthState {
  const AuthState();

  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(User user)? authenticated,
    T Function()? unauthenticated,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is _Initial && initial != null) {
      return initial();
    } else if (this is _Loading && loading != null) {
      return loading();
    } else if (this is _Authenticated && authenticated != null) {
      final s = this as _Authenticated;
      return authenticated(s.user);
    } else if (this is _Unauthenticated && unauthenticated != null) {
      return unauthenticated();
    } else if (this is _Error && error != null) {
      final s = this as _Error;
      return error(s.message);
    }
    return orElse();
  }
}

class _Initial extends AuthState {
  const _Initial();
}

class _Loading extends AuthState {
  const _Loading();
}

class _Authenticated extends AuthState {
  final User user;
  const _Authenticated(this.user);
}

class _Unauthenticated extends AuthState {
  const _Unauthenticated();
}

class _Error extends AuthState {
  final String message;
  const _Error(this.message);
}
