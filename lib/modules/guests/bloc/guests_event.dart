part of 'guests_bloc.dart';

@freezed
class GuestsEvent with _$GuestsEvent {
  const factory GuestsEvent.guestListRequested() = GuestListRequested;
}
