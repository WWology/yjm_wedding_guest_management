import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/user.dart';
import '../service/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
    : _authService = authService,
      super(const .initial()) {
    on<UserSubscriptionRequested>(_onUserSubscriptionRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogOutRequested>(_onLogOutRequested);
  }

  Future<void> _onUserSubscriptionRequested(
    UserSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    return emit.onEach(
      _authService.user,
      onData: (user) => emit(.authenticated(user)),
      onError: addError,
    );
  }

  FutureOr<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.loginWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
    } on LoginWithEmailAndPasswordFailure catch (e) {
      emit(.unauthenticated(message: e.message));
    }
  }

  FutureOr<void> _onLogOutRequested(
    LogOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.logOut();
    emit(const .unauthenticated());
  }
}
