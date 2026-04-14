import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String nom;
  final String contact;
  final String zoneID;
  final String role;
  final Timestamp date;
  final List<Map<String, dynamic>> tontines;

  AppUser({
    required this.uid,
    required this.email,
    required this.nom,
    required this.contact,
    required this.zoneID,
    required this.role,
    required this.date,
    this.tontines = const [],
  });

  factory AppUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppUser(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      nom: data['nom'] ?? '',
      contact: data['contact'] ?? '',
      zoneID: data['zoneID'] ?? '',
      role: data['role'] ?? '',
      date: data['date'] as Timestamp? ?? Timestamp.now(),
      tontines: List<Map<String, dynamic>>.from(
        data['tontines'] ?? <Map<String, dynamic>>[],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nom': nom,
      'contact': contact,
      'zoneID': zoneID,
      'role': role,
      'date': date,
      'tontines': tontines,
    };
  }
}
