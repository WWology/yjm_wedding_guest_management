part of 'auth_bloc.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.userSubscriptionRequested() =
      UserSubscriptionRequested;

  const factory AuthEvent.logOutRequested() = LogOutRequested;
}
