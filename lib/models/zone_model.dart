import 'package:cloud_firestore/cloud_firestore.dart';

class ZoneModel {
  final String id;
  final String nom;
  final Timestamp date;

  ZoneModel({
    required this.id,
    required this.nom,
    required this.date,
  });

  factory ZoneModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ZoneModel(
      id: doc.id,
      nom: data['nom'] ?? '',
      date: data['date'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'date': date,
    };
  }
}
