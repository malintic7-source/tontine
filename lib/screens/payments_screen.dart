import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/payment.dart';
import '../models/tontine.dart';
import '../models/zone_model.dart';
import '../services/firestore_service.dart';
import '../widgets/main_layout.dart';

class PaymentsScreen extends StatelessWidget {
  static const routeName = '/payments';
  final FirestoreService _service = FirestoreService();

  PaymentsScreen({super.key});

  Future<void> _showAddPaymentDialog(BuildContext context) async {
    final amountController = TextEditingController(text: '0');
    final motifController = TextEditingController();
    String? selectedUserId;
    String? selectedTontineId;
    String? selectedZoneId;
    double? tontineMontant;
    String selectedType = 'depot';
    String selectedStatut = 'en attente';
    final types = ['depot', 'retrait'];
    final statuts = ['en attente', 'valide', 'annule'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFF6E0),
                      const Color(0xFFFFF9E6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ajouter un paiement',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF866900),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildUserDropdown(
                        selectedUserId: selectedUserId,
                        onChanged: (value) {
                          setState(() {
                            selectedUserId = value;
                            selectedTontineId = null;
                            tontineMontant = null;
                            amountController.text = '0';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (selectedUserId != null)
                        _buildTontineDropdown(
                          selectedUserId: selectedUserId!,
                          selectedTontineId: selectedTontineId,
                          onChanged: (value, montant) {
                            setState(() {
                              selectedTontineId = value;
                              tontineMontant = montant;
                              amountController.text = montant.toInt().toString();
                            });
                          },
                        ),
                      if (selectedUserId != null) const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildStyledTextField(
                              controller: amountController,
                              label: 'Montant (FCFA)',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          if (tontineMontant != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF866900),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  final currentAmount = double.tryParse(amountController.text) ?? 0;
                                  final newAmount = currentAmount + (tontineMontant ?? 0);
                                  amountController.text = newAmount.toInt().toString();
                                },
                                icon: const Icon(Icons.add, color: Colors.white),
                                tooltip: 'Ajouter ${tontineMontant!.toInt()} FCFA',
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTypeDropdown(
                        selectedType: selectedType,
                        types: types,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildStatutDropdown(
                        selectedStatut: selectedStatut,
                        statuts: statuts,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedStatut = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildZoneDropdown(
                        selectedZoneId: selectedZoneId,
                        onChanged: (value) {
                          setState(() {
                            selectedZoneId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildStyledTextField(
                        controller: motifController,
                        label: 'Motif (optionnel)',
                        icon: Icons.description,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF866900),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Annuler',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              final montant =
                                  double.tryParse(amountController.text.trim()) ?? 0.0;
                              final currentUser = FirebaseAuth.instance.currentUser;
                              if (selectedUserId == null ||
                                  montant <= 0 ||
                                  selectedTontineId == null ||
                                  selectedZoneId == null) return;
                              final navigator = Navigator.of(context);

                              // 1. Créer le paiement
                              await _service.addPayement(
                                PaymentModel(
                                  id: '',
                                  uid: selectedUserId!,
                                  montant: montant,
                                  type: selectedType,
                                  date: Timestamp.now(),
                                  contact: '',
                                  statut: selectedStatut,
                                  motif: motifController.text.trim(),
                                  zoneID: selectedZoneId!,
                                  tontineId: selectedTontineId!,
                                  utilisateursAnciens: [],
                                  adminUID: currentUser?.uid ?? '',
                                ),
                              );

                              // 2. Mettre à jour la tontine (participants/utilisateursAnciens)
                              final tontineDoc = await FirebaseFirestore.instance
                                  .collection('tontines')
                                  .doc(selectedTontineId)
                                  .get();

                              if (tontineDoc.exists) {
                                final tontineData = tontineDoc.data() as Map<String, dynamic>;
                                List<Map<String, dynamic>> participants = List<Map<String, dynamic>>.from(
                                  tontineData['participants'] ?? <Map<String, dynamic>>[],
                                );
                                List<Map<String, dynamic>> anciens = List<Map<String, dynamic>>.from(
                                  tontineData['utilisateursAnciens'] ?? <Map<String, dynamic>>[],
                                );

                                // Chercher si l'utilisateur existe déjà dans participants
                                final participantIndex = participants.indexWhere(
                                  (p) => p['uid'] == selectedUserId,
                                );

                                if (selectedType == 'depot') {
                                  // Dépôt: ajouter ou augmenter le montant
                                  if (participantIndex >= 0) {
                                    // Utilisateur existe: augmenter le montant
                                    final currentMontant = (participants[participantIndex]['montant'] as num?)?.toDouble() ?? 0.0;
                                    participants[participantIndex]['montant'] = currentMontant + montant;
                                  } else {
                                    // Nouveau participant
                                    participants.add({
                                      'uid': selectedUserId,
                                      'montant': montant,
                                    });
                                  }
                                } else if (selectedType == 'retrait') {
                                  // Retrait: diminuer le montant
                                  if (participantIndex >= 0) {
                                    final currentMontant = (participants[participantIndex]['montant'] as num?)?.toDouble() ?? 0.0;
                                    final newMontant = currentMontant - montant;

                                    if (newMontant <= 0) {
                                      // Solde épuisé: déplacer vers anciens
                                      participants.removeAt(participantIndex);
                                      anciens.add({
                                        'uid': selectedUserId,
                                        'montant': 0.0,
                                      });
                                    } else {
                                      // Mettre à jour le montant
                                      participants[participantIndex]['montant'] = newMontant;
                                    }
                                  }
                                }

                                // Sauvegarder les modifications
                                await FirebaseFirestore.instance
                                    .collection('tontines')
                                    .doc(selectedTontineId)
                                    .update({
                                  'participants': participants,
                                  'utilisateursAnciens': anciens,
                                });
                              }

                              navigator.pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF866900),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Ajouter',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Color(0xFF2C2410),
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF866900),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF866900)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildUserDropdown({
    required String? selectedUserId,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: StreamBuilder<List<AppUser>>(
        stream: _service.utilisateursStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final users = snapshot.data!;
          return InputDecorator(
            decoration: InputDecoration(
              labelText: 'Utilisateur',
              labelStyle: const TextStyle(
                color: Color(0xFF866900),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Icon(Icons.person, color: Color(0xFF866900)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedUserId,
                hint: const Text(
                  'Sélectionner un utilisateur',
                  style: TextStyle(color: Color(0xFF6B5E45)),
                ),
                isExpanded: true,
                onChanged: onChanged,
                dropdownColor: Colors.white,
                style: const TextStyle(
                  color: Color(0xFF2C2410),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                iconEnabledColor: const Color(0xFF866900),
                items: users.map((user) {
                  return DropdownMenuItem(
                    value: user.uid,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        user.nom.isNotEmpty ? user.nom : user.email,
                        style: const TextStyle(
                          color: Color(0xFF2C2410),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTontineDropdown({
    required String selectedUserId,
    required String? selectedTontineId,
    required Function(String, double) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: StreamBuilder<List<TontineModel>>(
        stream: _service.tontinesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final allTontines = snapshot.data!;
          // Filtrer les tontines où l'utilisateur est participant
          final userTontines = allTontines.where((t) {
            return t.participants.any((p) => p['uid'] == selectedUserId);
          }).toList();

          if (userTontines.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Aucune tontine pour cet utilisateur',
                style: TextStyle(color: Color(0xFF6B5E45)),
              ),
            );
          }

          return InputDecorator(
            decoration: InputDecoration(
              labelText: 'Tontine',
              labelStyle: const TextStyle(
                color: Color(0xFF866900),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Icon(Icons.group, color: Color(0xFF866900)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedTontineId,
                hint: const Text(
                  'Sélectionner une tontine',
                  style: TextStyle(color: Color(0xFF6B5E45)),
                ),
                isExpanded: true,
                onChanged: (value) {
                  if (value != null) {
                    final tontine = userTontines.firstWhere((t) => t.id == value);
                    onChanged(value, tontine.montantMinimum);
                  }
                },
                dropdownColor: Colors.white,
                style: const TextStyle(
                  color: Color(0xFF2C2410),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                iconEnabledColor: const Color(0xFF866900),
                items: userTontines.map((tontine) {
                  return DropdownMenuItem(
                    value: tontine.id,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${tontine.nom} (${tontine.montantMinimum.toInt()} FCFA)',
                        style: const TextStyle(
                          color: Color(0xFF2C2410),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildZoneDropdown({
    required String? selectedZoneId,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: StreamBuilder<List<ZoneModel>>(
        stream: _service.zonesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final zones = snapshot.data!;
          return InputDecorator(
            decoration: InputDecoration(
              labelText: 'Zone',
              labelStyle: const TextStyle(
                color: Color(0xFF866900),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Icon(Icons.location_on, color: Color(0xFF866900)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedZoneId,
                hint: const Text(
                  'Sélectionner une zone',
                  style: TextStyle(color: Color(0xFF6B5E45)),
                ),
                isExpanded: true,
                onChanged: onChanged,
                dropdownColor: Colors.white,
                style: const TextStyle(
                  color: Color(0xFF2C2410),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                iconEnabledColor: const Color(0xFF866900),
                items: zones.map((zone) {
                  return DropdownMenuItem(
                    value: zone.id,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        zone.nom,
                        style: const TextStyle(
                          color: Color(0xFF2C2410),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeDropdown({
    required String selectedType,
    required List<String> types,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Type',
          labelStyle: const TextStyle(
            color: Color(0xFF866900),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.category, color: Color(0xFF866900)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedType,
            isExpanded: true,
            onChanged: onChanged,
            dropdownColor: Colors.white,
            style: const TextStyle(
              color: Color(0xFF2C2410),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            iconEnabledColor: const Color(0xFF866900),
            items: types.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    type,
                    style: const TextStyle(
                      color: Color(0xFF2C2410),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatutDropdown({
    required String selectedStatut,
    required List<String> statuts,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Statut',
          labelStyle: const TextStyle(
            color: Color(0xFF866900),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.flag, color: Color(0xFF866900)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedStatut,
            isExpanded: true,
            onChanged: onChanged,
            dropdownColor: Colors.white,
            style: const TextStyle(
              color: Color(0xFF2C2410),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            iconEnabledColor: const Color(0xFF866900),
            items: statuts.map((statut) {
              return DropdownMenuItem(
                value: statut,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    statut,
                    style: const TextStyle(
                      color: Color(0xFF2C2410),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Paiements',
      selectedIndex: 3,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<List<PaymentModel>>(
              stream: _service.payementsStream(),
              builder: (context, paymentSnapshot) {
                if (paymentSnapshot.hasError) {
                  return const Center(
                    child: Text('Erreur de chargement des paiements'),
                  );
                }
                if (!paymentSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final payements = paymentSnapshot.data!;

                return StreamBuilder<List<AppUser>>(
                  stream: _service.utilisateursStream(),
                  builder: (context, userSnapshot) {
                    final users = userSnapshot.data ?? [];
                    final userMap = {for (var u in users) u.uid: u.nom};

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          color: const Color(0xFFFFF6E0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF866900),
                              child: Icon(Icons.payment, color: Colors.white),
                            ),
                            title: const Text(
                              'Paiements récents',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${payements.length} paiements enregistrés'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: payements.isEmpty
                              ? const Center(child: Text('Aucun paiement enregistré'))
                              : ListView.separated(
                                  itemCount: payements.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final payment = payements[index];
                                    final userName = userMap[payment.uid] ?? 'Inconnu';
                                    return _PaymentCard(
                                      payment: payment,
                                      userName: userName,
                                      onTap: () => _showPaymentDetailsDialog(context, payment, userName),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFFFFC800),
              onPressed: () => _showAddPaymentDialog(context),
              child: const Icon(Icons.add, color: Color(0xFF866900)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPaymentDetailsDialog(BuildContext context, PaymentModel payment, String userName) async {
    final dateFormat = payment.date.toDate();
    final dateStr = '${dateFormat.day}/${dateFormat.month}/${dateFormat.year} ${dateFormat.hour}:${dateFormat.minute.toString().padLeft(2, '0')}';

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFF6E0),
                  const Color(0xFFFFF9E6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.payment,
                        color: Color(0xFF866900),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Détails du paiement',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF866900),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('ID', payment.id),
                  const SizedBox(height: 12),
                  _buildDetailRow('Montant', '${payment.montant.toStringAsFixed(0)} CFA'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Type', payment.type),
                  const SizedBox(height: 12),
                  _buildDetailRow('Statut', payment.statut),
                  const SizedBox(height: 12),
                  _buildDetailRow('Date', dateStr),
                  const SizedBox(height: 12),
                  _buildDetailRow('Utilisateur', userName),
                  const SizedBox(height: 12),
                  _buildDetailRow('Zone ID', payment.zoneID),
                  const SizedBox(height: 12),
                  _buildDetailRow('Contact', payment.contact.isNotEmpty ? payment.contact : 'Non renseigné'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Motif', payment.motif.isNotEmpty ? payment.motif : 'Non renseigné'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Admin ID', payment.adminUID),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF866900),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Fermer',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF866900),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2C2410),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final String userName;
  final VoidCallback onTap;

  const _PaymentCard({
    required this.payment,
    required this.userName,
    required this.onTap,
  });

  Color _getStatutColor() {
    switch (payment.statut.toLowerCase()) {
      case 'valide':
        return Colors.green;
      case 'annule':
      case 'annulé':
        return Colors.red;
      case 'en attente':
      default:
        return const Color(0xFF866900);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 2,
      color: const Color(0xFFFFF6E0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.payment,
                    color: Color(0xFF866900),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${payment.type} — ${payment.montant.toStringAsFixed(0)} CFA',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF866900),
                          ),
                        ),
                        Text(
                          'Par: $userName',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B5E45),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      payment.statut,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: _getStatutColor(),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const Divider(color: Color(0xFF866900), height: 16),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Color(0xFF6B5E45)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${payment.date.toDate().day}/${payment.date.toDate().month}/${payment.date.toDate().year}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B5E45),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: _getStatutColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    payment.statut,
                    style: TextStyle(
                      fontSize: 13,
                      color: _getStatutColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
