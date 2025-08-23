import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  AuthNotifier(this._userRepository) : super(const AuthState.initial()) {
    _checkAuthState();
  }

  void _checkAuthState() {
    _firebaseAuth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        _loadUser(firebaseUser);
      } else {
        state = const AuthState.unauthenticated();
      }
    });
  }

  Future<void> _loadUser(firebase_auth.User firebaseUser) async {
    state = const AuthState.loading();

    final result = await _userRepository.getCurrentUser();
    result.fold((failure) => state = AuthState.error(failure.message), (user) {
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        // Create new user
        _createUser(firebaseUser);
      }
    });
  }

  Future<void> _createUser(firebase_auth.User firebaseUser) async {
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
      (failure) => state = AuthState.error(failure.message),
      (savedUser) => state = AuthState.authenticated(savedUser),
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AuthState.loading();

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // User will be loaded automatically via auth state listener
    } on firebase_auth.FirebaseAuthException catch (e) {
      state = AuthState.error(_getAuthErrorMessage(e.code));
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AuthState.loading();

    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // User will be created automatically via auth state listener
    } on firebase_auth.FirebaseAuthException catch (e) {
      state = AuthState.error(_getAuthErrorMessage(e.code));
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();
      if (googleUser == null) {
        state = const AuthState.unauthenticated();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      // User will be loaded automatically via auth state listener
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    state = const AuthState.unauthenticated();
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
