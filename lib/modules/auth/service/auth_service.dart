import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:google_sign_in/google_sign_in.dart';

import '../model/user.dart';

class AuthService {
  AuthService({fba.FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignin})
    : _firebaseAuth = firebaseAuth ?? fba.FirebaseAuth.instance,
      _googleSignin = googleSignin ?? GoogleSignIn.instance;

  final fba.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignin;

  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser?.toUser;
      return user;
    });
  }

  User? get currentUser {
    return fba.FirebaseAuth.instance.currentUser?.toUser;
  }

  Future<void> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fba.FirebaseAuthException catch (e) {
      throw SignUpFailure.fromCode(e.code);
    } catch (e, s) {
      throw SignUpFailure('An unknown exception occurred.', s);
    }
  }

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fba.FirebaseAuthException catch (e) {
      throw LoginWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (e, s) {
      throw LoginWithEmailAndPasswordFailure(
        'An unknown exception occurred.',
        s,
      );
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      late final fba.AuthCredential credential;
      final googleProvider = fba.GoogleAuthProvider();
      final userCredential = await _firebaseAuth.signInWithPopup(
        googleProvider,
      );
      credential = userCredential.credential!;
      await _firebaseAuth.signInWithCredential(credential);
    } on fba.FirebaseAuthException catch (e) {
      throw LoginWithGoogleFailure.fromCode(e.code);
    } catch (e, s) {
      throw LoginWithGoogleFailure('An unknown exception occurred.', s);
    }
  }

  Future<void> logOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignin.signOut()]);
    } catch (e, s) {
      throw LogoutFailure('An unknown exception occurred.', s);
    }
  }
}

extension on fba.User {
  User get toUser {
    return User(id: uid, email: email, name: displayName);
  }
}

class SignUpFailure implements Exception {
  const SignUpFailure([
    this.message = 'An unknown exception occurred.',
    this.stackTrace,
  ]);

  final String message;
  final StackTrace? stackTrace;

  factory SignUpFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const SignUpFailure('Email is not valid or badly formatted.');
      case 'user-disabled':
        return const SignUpFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'email-already-in-use':
        return const SignUpFailure('An account already exists for that email.');
      case 'operation-not-allowed':
        return const SignUpFailure(
          'Operation is not allowed. Please contact support.',
        );
      case 'weak-password':
        return const SignUpFailure('Please enter a stronger password.');
      default:
        return const SignUpFailure();
    }
  }

  @override
  String toString() => 'SignUpFailure: $message';
}

class LoginWithEmailAndPasswordFailure implements Exception {
  const LoginWithEmailAndPasswordFailure([
    this.message = 'An unknown exception occurred.',
    this.stackTrace,
  ]);

  final String message;
  final StackTrace? stackTrace;

  factory LoginWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const LoginWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
        );
      case 'user-disabled':
        return const LoginWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LoginWithEmailAndPasswordFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LoginWithEmailAndPasswordFailure(
          'Incorrect password, please try again.',
        );
      default:
        return const LoginWithEmailAndPasswordFailure();
    }
  }

  @override
  String toString() => 'LoginWithEmailAndPasswordFailure: $message';
}

class LoginWithGoogleFailure implements Exception {
  const LoginWithGoogleFailure([
    this.message = 'An unknown exception occurred.',
    this.stackTrace,
  ]);

  final String message;
  final StackTrace? stackTrace;

  factory LoginWithGoogleFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LoginWithGoogleFailure(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return const LoginWithGoogleFailure(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return const LoginWithGoogleFailure(
          'Operation is not allowed. Please contact support.',
        );
      case 'user-disabled':
        return const LoginWithGoogleFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LoginWithGoogleFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LoginWithGoogleFailure(
          'Incorrect password, please try again.',
        );
      case 'invalid-verification-code':
        return const LoginWithGoogleFailure(
          'The credential verification code received is invalid.',
        );
      case 'invalid-verification-id':
        return const LoginWithGoogleFailure(
          'The credential verification ID received is invalid.',
        );
      default:
        return const LoginWithGoogleFailure();
    }
  }

  @override
  String toString() => 'LoginWithGoogleFailure: $message';
}

class LogoutFailure implements Exception {
  const LogoutFailure([
    this.message = 'An unknown exception occurred.',
    this.stackTrace,
  ]);

  final String message;
  final StackTrace? stackTrace;

  @override
  String toString() => 'LogoutFailure: $message';
}
