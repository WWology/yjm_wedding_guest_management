part of 'auth_bloc.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.userSubscriptionRequested() =
      UserSubscriptionRequested;

  factory AuthEvent.loginRequested({
    required String email,
    required String password,
  }) = LoginRequested;

  const factory AuthEvent.logOutRequested() = LogOutRequested;
}
