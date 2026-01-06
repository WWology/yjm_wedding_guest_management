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
      super(const .unauthenticated()) {
    on<UserSubscriptionRequested>(_onUserSubscriptionRequested);
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

  FutureOr<void> _onLogOutRequested(
    LogOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.logOut();
    emit(const .unauthenticated());
  }
}
