import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/guest.dart';
import '../service/guest_service.dart';

part 'guests_event.dart';
part 'guests_state.dart';
part 'guests_bloc.freezed.dart';

class GuestsBloc extends Bloc<GuestsEvent, GuestsState> {
  final GuestService _guestService;
  StreamSubscription<List<Guest>>? _guestSubscription;

  GuestsBloc({required GuestService guestService})
    : _guestService = guestService,
      super(const .initial()) {
    on<GuestListRequested>(_onGuestListRequested);
    on<GuestListUpdated>(_onGuestListUpdated);
  }

  @override
  Future<void> close() {
    _guestSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> _onGuestListRequested(
    GuestListRequested event,
    Emitter<GuestsState> emit,
  ) async {
    emit(const .loading());
    _guestSubscription?.cancel();
    _guestSubscription = _guestService.first10Guests.listen(
      (guests) {
        add(.guestListUpdated(guests: guests));
      },
      onError: (_) {
        emit(const .error());
      },
    );
  }

  FutureOr<void> _onGuestListUpdated(
    GuestListUpdated event,
    Emitter<GuestsState> emit,
  ) {
    emit(.guestListLoaded(guests: event.guests));
  }
}
