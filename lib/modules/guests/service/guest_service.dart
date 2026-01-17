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
    final guestsSnapshot = _guestsRef.limit(10).orderBy('name').snapshots();

    return guestsSnapshot.map(
      (snapshot) => snapshot.docs.map((doc) {
        if (doc == snapshot.docs.last) {
          _nextCursor = doc;
          _prevCursor = null;
        }
        return doc.data();
      }).toList(),
    );
  }

  Future<int?> get guestCount async {
    final res = await _guestsRef.count().get();
    return res.count;
  }

  Stream<List<Guest>> get next10Guests => _guestsRef
      .startAfterDocument(_nextCursor!)
      .limit(10)
      .orderBy('name')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  Stream<List<Guest>> get previous10Guests => _guestsRef
      .endBeforeDocument(_prevCursor!)
      .limitToLast(10)
      .orderBy('name')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}
