part of 'auth_bloc.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.unauthenticated({String? message}) = Unauthenticated;
  const factory AuthState.loading() = Loading;
  const factory AuthState.authenticated(User user) = Authenticated;
  const factory AuthState.failure(String message) = Failure;
}
