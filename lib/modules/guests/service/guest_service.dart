import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/guest.dart';

class GuestService {
  final CollectionReference<Guest> _guestsRef;
  static DocumentSnapshot? _nextCursor;
  static DocumentSnapshot? _prevCursor;

  GuestService({CollectionReference<Guest>? guestsCollection})
    : _guestsRef =
          guestsCollection ??
          FirebaseFirestore.instance
              .collection('guests')
              .withConverter<Guest>(
                fromFirestore: (snapshot, _) =>
                    Guest.fromJson(snapshot.data()!),
                toFirestore: (guest, _) => guest.toJson(),
              );

  Stream<List<Guest>> get first10Guests {
    final guestsSnapshot = _guestsRef.limit(11).orderBy('name').snapshots();

    return guestsSnapshot.map((snapshot) {
      if (snapshot.docs.length > 10) {
        _nextCursor = snapshot.docs.last;
      } else {
        _nextCursor = null;
      }

      return snapshot.docs.take(10).map((doc) => doc.data()).toList();
    });
  }

  Stream<List<Guest>> get next10Guests {
    if (!hasNextPage) return Stream.value([]);
    _prevCursor = _nextCursor;

    final nextGuestsSnapshot = _guestsRef
        .startAtDocument(_nextCursor!)
        .limit(11)
        .orderBy('name')
        .snapshots();

    return nextGuestsSnapshot.map((snapshot) {
      final notLastPage = snapshot.docs.length > 10;
      if (notLastPage) {
        _nextCursor = snapshot.docs.last;
      } else {
        _nextCursor = null;
      }

      return snapshot.docs.take(10).map((doc) => doc.data()).toList();
    });
  }

  Stream<List<Guest>> get previous10Guests {
    if (isFirstPage) {
      return first10Guests;
    }

    _nextCursor = _prevCursor;

    final prevGuestsSnapshot = _guestsRef
        .endBeforeDocument(_prevCursor!)
        .limitToLast(11)
        .orderBy('name')
        .snapshots();

    return prevGuestsSnapshot.map((snapshot) {
      final notFirstPage = snapshot.docs.length > 10;
      if (notFirstPage) {
        _prevCursor = snapshot.docs[1];
        return snapshot.docs.skip(1).map((doc) => doc.data()).toList();
      } else {
        _prevCursor = null;
        return snapshot.docs.map((doc) => doc.data()).toList();
      }
    });
  }

  bool get isFirstPage => _prevCursor == null;
  bool get hasNextPage => _nextCursor != null;

  Future<int?> get guestCount async {
    final res = await _guestsRef.count().get();
    return res.count;
  }
}
