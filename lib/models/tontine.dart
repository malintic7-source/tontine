import 'package:cloud_firestore/cloud_firestore.dart';

class TontineModel {
  final String id;
  final String nom;
  final double montantMinimum;
  final String zoneID;
  final List<Map<String, dynamic>> participants;
  final List<Map<String, dynamic>> utilisateursAnciens;
  final String adminUID;
  final String statut;
  final String motif;
  final Timestamp date;

  TontineModel({
    required this.id,
    required this.nom,
    required this.montantMinimum,
    required this.zoneID,
    required this.participants,
    required this.utilisateursAnciens,
    required this.adminUID,
    required this.statut,
    required this.motif,
    required this.date,
  });

  factory TontineModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TontineModel(
      id: doc.id,
      nom: data['nom'] ?? '',
      montantMinimum: (data['montantMinimum'] as num?)?.toDouble() ?? 0.0,
      zoneID: data['zoneID'] ?? '',
      participants: List<Map<String, dynamic>>.from(
        data['participants'] ?? <Map<String, dynamic>>[],
      ),
      utilisateursAnciens: List<Map<String, dynamic>>.from(
        data['utilisateursAnciens'] ?? <Map<String, dynamic>>[],
      ),
      adminUID: data['adminUID'] ?? '',
      statut: data['statut'] ?? 'active',
      motif: data['motif'] ?? '',
      date: data['date'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'montantMinimum': montantMinimum,
      'zoneID': zoneID,
      'participants': participants,
      'utilisateursAnciens': utilisateursAnciens,
      'adminUID': adminUID,
      'statut': statut,
      'motif': motif,
      'date': date,
    };
  }
}
