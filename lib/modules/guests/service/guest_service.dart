import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/guest.dart';

class GuestService {
  final CollectionReference<Guest> _guestsCollection;

  GuestService({CollectionReference<Guest>? guestsCollection})
    : _guestsCollection =
          guestsCollection ??
          FirebaseFirestore.instance
              .collection('guests')
              .withConverter<Guest>(
                fromFirestore: (snapshot, _) =>
                    Guest.fromJson(snapshot.data()!),
                toFirestore: (guest, _) => guest.toJson(),
              );

  Stream<List<Guest>> get guestsSnapshot => _guestsCollection
      .limit(10)
      .orderBy('name')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}
