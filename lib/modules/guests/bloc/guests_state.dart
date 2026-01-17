part of 'guests_bloc.dart';

@freezed
class GuestsState with _$GuestsState {
  const factory GuestsState.initial() = _Initial;
  const factory GuestsState.loading() = Loading;
  const factory GuestsState.guestListLoaded({required List<Guest> guests}) =
      GuestListLoaded;
  const factory GuestsState.error() = Error;
}
