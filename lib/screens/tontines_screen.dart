import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../models/tontine.dart';
import '../models/zone_model.dart';
import '../services/firestore_service.dart';
import '../widgets/main_layout.dart';

class TontinesScreen extends StatelessWidget {
  static const routeName = '/tontines';
  final FirestoreService _service = FirestoreService();

  TontinesScreen({super.key});

  Future<void> _showAddTontineDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final motifController = TextEditingController();
    String? selectedZoneId;
    String selectedStatut = 'active';
    final statuts = ['active', 'inactive', 'suspendue', 'terminee'];
    final currentUser = FirebaseAuth.instance.currentUser;

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
                        'Ajouter une tontine',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF866900),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildStyledTextField(
                        controller: nameController,
                        label: 'Nom de la tontine',
                        icon: Icons.group,
                      ),
                      const SizedBox(height: 16),
                      _buildStyledTextField(
                        controller: amountController,
                        label: 'Montant minimum (FCFA)',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
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
                              if (nameController.text.trim().isEmpty ||
                                  montant <= 0 ||
                                  selectedZoneId == null) return;
                              final navigator = Navigator.of(context);
                              await _service.addTontine(
                                TontineModel(
                                  id: '',
                                  nom: nameController.text.trim(),
                                  montantMinimum: montant,
                                  zoneID: selectedZoneId!,
                                  participants: [],
                                  utilisateursAnciens: [],
                                  adminUID: currentUser?.uid ?? '',
                                  statut: selectedStatut,
                                  motif: motifController.text.trim(),
                                  date: Timestamp.now(),
                                ),
                              );
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
      title: 'Tontines',
      selectedIndex: 2,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<List<TontineModel>>(
              stream: _service.tontinesStream(),
              builder: (context, tontineSnapshot) {
                if (tontineSnapshot.hasError) {
                  return const Center(
                    child: Text('Erreur de chargement des tontines'),
                  );
                }
                if (!tontineSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tontines = tontineSnapshot.data!;

                return StreamBuilder<List<ZoneModel>>(
                  stream: _service.zonesStream(),
                  builder: (context, zoneSnapshot) {
                    final zones = zoneSnapshot.data ?? [];
                    final zoneMap = {for (var z in zones) z.id: z.nom};

                    return StreamBuilder<List<PaymentModel>>(
                      stream: _service.payementsStream(),
                      builder: (context, paymentSnapshot) {
                        final payments = paymentSnapshot.data ?? [];

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
                                  child: Icon(Icons.group, color: Colors.white),
                                ),
                                title: const Text(
                                  'Tontines actives',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('${tontines.length} tontines enregistrées'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: tontines.isEmpty
                                  ? const Center(child: Text('Aucune tontine disponible'))
                                  : ListView.separated(
                                      itemCount: tontines.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final tontine = tontines[index];
                                        // Calculer le total des paiements pour cette tontine
                                        final tontinePayments = payments.where((p) => p.tontineId == tontine.id).toList();
                                        final totalPayments = tontinePayments.fold<double>(
                                          0.0,
                                          (sum, p) => sum + p.montant,
                                        );

                                        return _TontineCard(
                                          tontine: tontine,
                                          zoneName: zoneMap[tontine.zoneID] ?? tontine.zoneID,
                                          totalPayments: totalPayments,
                                          onTap: () => _showTontineDetailsDialog(context, tontine, zoneMap[tontine.zoneID] ?? tontine.zoneID, totalPayments),
                                          onEdit: () => _showEditTontineDialog(context, tontine),
                                          onDelete: () => _showDeleteTontineDialog(context, tontine),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
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
              onPressed: () => _showAddTontineDialog(context),
              child: const Icon(Icons.add, color: Color(0xFF866900)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTontineDetailsDialog(BuildContext context, TontineModel tontine, String zoneName, double totalPayments) async {
    final dateFormat = tontine.date.toDate();
    final dateStr = '${dateFormat.day}/${dateFormat.month}/${dateFormat.year}';

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
                        Icons.group,
                        color: Color(0xFF866900),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tontine.nom,
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
                  _buildDetailRow('ID', tontine.id),
                  const SizedBox(height: 12),
                  _buildDetailRow('Montant min', '${tontine.montantMinimum.toInt()} FCFA'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Zone', zoneName),
                  const SizedBox(height: 12),
                  _buildDetailRow('Total payé', '${totalPayments.toInt()} FCFA'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Statut', tontine.statut),
                  const SizedBox(height: 12),
                  _buildDetailRow('Date', dateStr),
                  const SizedBox(height: 12),
                  _buildDetailRow('Admin ID', tontine.adminUID.isNotEmpty ? tontine.adminUID : 'Non assigné'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Motif', tontine.motif.isNotEmpty ? tontine.motif : 'Aucun'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Participants', '${tontine.participants.length} membres'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Anciens', '${tontine.utilisateursAnciens.length} utilisateurs'),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
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
                    ],
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
          width: 110,
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

  Future<void> _showEditTontineDialog(BuildContext context, TontineModel tontine) async {
    final nameController = TextEditingController(text: tontine.nom);
    final amountController = TextEditingController(text: tontine.montantMinimum.toInt().toString());
    final motifController = TextEditingController(text: tontine.motif);
    String? selectedZoneId = tontine.zoneID;
    String selectedStatut = tontine.statut;
    final statuts = ['active', 'inactive', 'suspendue', 'terminee'];

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
                        'Modifier la tontine',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF866900),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildStyledTextField(
                        controller: nameController,
                        label: 'Nom de la tontine',
                        icon: Icons.group,
                      ),
                      const SizedBox(height: 16),
                      _buildStyledTextField(
                        controller: amountController,
                        label: 'Montant minimum (FCFA)',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
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
                              if (nameController.text.trim().isEmpty ||
                                  montant <= 0 ||
                                  selectedZoneId == null) return;
                              await FirebaseFirestore.instance
                                  .collection('tontines')
                                  .doc(tontine.id)
                                  .update({
                                'nom': nameController.text.trim(),
                                'montantMinimum': montant,
                                'zoneID': selectedZoneId,
                                'statut': selectedStatut,
                                'motif': motifController.text.trim(),
                              });
                              Navigator.pop(context);
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
                              'Modifier',
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

  Future<void> _showDeleteTontineDialog(BuildContext context, TontineModel tontine) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Supprimer la tontine',
            style: TextStyle(
              color: Color(0xFF866900),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer la tontine "${tontine.nom}" ? Cette action est irréversible.',
            style: const TextStyle(color: Color(0xFF2C2410)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Color(0xFF866900)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('tontines')
                    .doc(tontine.id)
                    .delete();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}

class _TontineCard extends StatelessWidget {
  final TontineModel tontine;
  final String zoneName;
  final double totalPayments;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TontineCard({
    required this.tontine,
    required this.zoneName,
    required this.totalPayments,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getStatutColor() {
    switch (tontine.statut.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'terminee':
      case 'terminée':
        return Colors.blue;
      case 'suspendue':
        return Colors.orange;
      case 'inactive':
      default:
        return Colors.grey;
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.group,
                    color: Color(0xFF866900),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tontine.nom,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF866900),
                          ),
                        ),
                        Text(
                          'ID: ${tontine.id.substring(0, tontine.id.length > 8 ? 8 : tontine.id.length)}...',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B5E45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF866900), size: 20),
                        onPressed: onEdit,
                        tooltip: 'Modifier',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: onDelete,
                        tooltip: 'Supprimer',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Color(0xFF866900), height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.attach_money,
                      '${tontine.montantMinimum.toInt()} FCFA',
                      'Montant min',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.location_on,
                      zoneName.length > 8 ? '${zoneName.substring(0, 8)}...' : zoneName,
                      'Zone',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.account_balance_wallet,
                      '${totalPayments.toInt()}',
                      'Total FCFA',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.people,
                      '${tontine.participants.length}',
                      'Membres',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(
                      tontine.statut,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: _getStatutColor(),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  if (tontine.motif.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Motif: ${tontine.motif}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B5E45),
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF866900), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF866900),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B5E45),
          ),
        ),
      ],
    );
  }
}
