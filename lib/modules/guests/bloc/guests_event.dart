part of 'guests_bloc.dart';

@freezed
class GuestsEvent with _$GuestsEvent {
  const factory GuestsEvent.guestListRequested() = GuestListRequested;
  const factory GuestsEvent.guestListUpdated({required List<Guest> guests}) =
      GuestListUpdated;
}
