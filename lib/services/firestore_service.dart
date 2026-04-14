import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/zone_model.dart';
import '../models/tontine.dart';
import '../models/payment.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String utilisateursCollection = 'utilisateurs';
  static const String zonesCollection = 'zones';
  static const String tontinesCollection = 'tontines';
  static const String payementsCollection = 'payements';

  Stream<List<AppUser>> utilisateursStream() {
    return _db
        .collection(utilisateursCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => AppUser.fromDocument(doc)).toList(),
        )
        .asBroadcastStream();
  }

  Stream<List<ZoneModel>> zonesStream() {
    return _db
        .collection(zonesCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ZoneModel.fromDocument(doc)).toList(),
        )
        .asBroadcastStream();
  }

  Stream<List<TontineModel>> tontinesStream() {
    return _db
        .collection(tontinesCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TontineModel.fromDocument(doc))
              .toList(),
        )
        .asBroadcastStream();
  }

  Stream<List<PaymentModel>> payementsStream() {
    return _db
        .collection(payementsCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PaymentModel.fromDocument(doc))
              .toList(),
        )
        .asBroadcastStream();
  }

  Future<AppUser?> getUtilisateurByUid(String uid) async {
    final snapshot = await _db
        .collection(utilisateursCollection)
        .doc(uid)
        .get();
    if (!snapshot.exists) return null;
    return AppUser.fromDocument(snapshot);
  }

  Future<void> addUtilisateur(AppUser utilisateur) {
    return _db
        .collection(utilisateursCollection)
        .doc(utilisateur.uid)
        .set(utilisateur.toMap());
  }

  Future<void> addZone(ZoneModel zone) {
    return _db.collection(zonesCollection).add(zone.toMap());
  }

  Future<void> addTontine(TontineModel tontine) {
    return _db.collection(tontinesCollection).add(tontine.toMap());
  }

  Future<void> addPayement(PaymentModel payement) {
    return _db.collection(payementsCollection).add(payement.toMap());
  }
}
