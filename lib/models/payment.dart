import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String uid;
  final double montant;
  final String type;
  final Timestamp date;
  final String contact;
  final String statut;
  final String motif;
  final String zoneID;
  final String tontineId;
  final List<Map<String, dynamic>> utilisateursAnciens;
  final String adminUID;

  PaymentModel({
    required this.id,
    required this.uid,
    required this.montant,
    required this.type,
    required this.date,
    required this.contact,
    required this.statut,
    required this.motif,
    required this.zoneID,
    required this.tontineId,
    required this.utilisateursAnciens,
    required this.adminUID,
  });

  factory PaymentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PaymentModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      montant: (data['montant'] as num?)?.toDouble() ?? 0.0,
      type: data['type'] ?? '',
      date: data['date'] as Timestamp? ?? Timestamp.now(),
      contact: data['contact'] ?? '',
      statut: data['statut'] ?? '',
      motif: data['motif'] ?? '',
      zoneID: data['zoneID'] ?? '',
      tontineId: data['tontineId'] ?? '',
      utilisateursAnciens: List<Map<String, dynamic>>.from(
        data['utilisateursAnciens'] ?? <Map<String, dynamic>>[],
      ),
      adminUID: data['adminUID'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'montant': montant,
      'type': type,
      'date': date,
      'contact': contact,
      'statut': statut,
      'motif': motif,
      'zoneID': zoneID,
      'tontineId': tontineId,
      'utilisateursAnciens': utilisateursAnciens,
      'adminUID': adminUID,
    };
  }
}
