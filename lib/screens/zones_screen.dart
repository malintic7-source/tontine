import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_user.dart';
import '../models/payment.dart';
import '../models/tontine.dart';
import '../models/zone_model.dart';
import '../services/firestore_service.dart';
import '../widgets/main_layout.dart';

class ZonesScreen extends StatelessWidget {
  static const routeName = '/zones';
  final FirestoreService _service = FirestoreService();

  ZonesScreen({super.key});

  Future<void> _showAddZoneDialog(BuildContext context) {
    final nameController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ajouter une zone',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF866900),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
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
                    controller: nameController,
                    style: const TextStyle(
                      color: Color(0xFF2C2410),
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nom de la zone',
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
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
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
                      onPressed: () {
                        final zoneName = nameController.text.trim();
                        if (zoneName.isEmpty) return;
                        _service.addZone(
                          ZoneModel(id: '', nom: zoneName, date: Timestamp.now()),
                        );
                        Navigator.pop(dialogContext);
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Zones',
      selectedIndex: 1,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<List<ZoneModel>>(
              stream: _service.zonesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erreur de chargement des zones'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final zones = snapshot.data!;
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
                          child: Icon(Icons.location_on, color: Colors.white),
                        ),
                        title: const Text(
                          'Zones actives',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${zones.length} zones enregistrées'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: zones.isEmpty
                          ? const Center(child: Text('Aucune zone enregistrée'))
                          : ListView.separated(
                              itemCount: zones.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final zone = zones[index];
                                return _ZoneCard(
                                  zone: zone,
                                  service: _service,
                                  onEdit: () => _showEditZoneDialog(context, zone),
                                  onDelete: () => _showDeleteZoneDialog(context, zone),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFFFFC800),
              onPressed: () => _showAddZoneDialog(context),
              child: const Icon(Icons.add, color: Color(0xFF866900)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditZoneDialog(BuildContext context, ZoneModel zone) {
    final nameController = TextEditingController(text: zone.nom);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Modifier la zone',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF866900),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
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
                    controller: nameController,
                    style: const TextStyle(
                      color: Color(0xFF2C2410),
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nom de la zone',
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
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
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
                        final zoneName = nameController.text.trim();
                        if (zoneName.isEmpty) return;
                        await FirebaseFirestore.instance
                            .collection('zones')
                            .doc(zone.id)
                            .update({'nom': zoneName});
                        Navigator.pop(dialogContext);
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
        );
      },
    );
  }

  Future<void> _showDeleteZoneDialog(BuildContext context, ZoneModel zone) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Supprimer la zone',
            style: TextStyle(
              color: Color(0xFF866900),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer la zone "${zone.nom}" ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF866900),
              ),
              child: const Text(
                'Annuler',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('zones')
                    .doc(zone.id)
                    .delete();
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Supprimer',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final ZoneModel zone;
  final FirestoreService service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ZoneCard({
    required this.zone,
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      color: const Color(0xFFFFF6E0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF866900),
                  child: Icon(Icons.location_on, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.nom,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF866900),
                        ),
                      ),
                      Text(
                        'ID: ${zone.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B5E45),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Color(0xFF866900)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: zone.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ID copié'),
                        backgroundColor: Color(0xFF866900),
                      ),
                    );
                  },
                  tooltip: 'Copier l\'ID',
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF866900)),
                  onPressed: onEdit,
                  tooltip: 'Modifier',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Supprimer',
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<AppUser>>(
              stream: service.utilisateursStream(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = userSnapshot.data!;
                final zoneUsers = users.where((u) => u.zoneID == zone.id).toList();
                final admins = zoneUsers.where((u) => u.role.toLowerCase() == 'admin').length;
                final agents = zoneUsers.where((u) => u.role.toLowerCase() == 'agent').length;
                final cotisants = zoneUsers.where((u) => u.role.toLowerCase() == 'cotisant').length;

                return StreamBuilder<List<TontineModel>>(
                  stream: service.tontinesStream(),
                  builder: (context, tontineSnapshot) {
                    if (!tontineSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final tontines = tontineSnapshot.data!;
                    final zoneTontines = tontines.where((t) => t.zoneID == zone.id).toList();
                    final activeTontines = zoneTontines.length;
                    final inactiveTontines = 0;

                    return StreamBuilder<List<PaymentModel>>(
                      stream: service.payementsStream(),
                      builder: (context, paymentSnapshot) {
                        if (!paymentSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final payments = paymentSnapshot.data!;
                        final zonePayments = payments.where((p) {
                          final user = users.firstWhere(
                            (u) => u.uid == p.uid,
                            orElse: () => users.isNotEmpty ? users.first : AppUser(
                              uid: '',
                              email: '',
                              nom: '',
                              contact: '',
                              zoneID: '',
                              role: '',
                              date: Timestamp.now(),
                            ),
                          );
                          return user.zoneID == zone.id;
                        }).toList();

                        final deposits = zonePayments.where((p) => p.type.toLowerCase() == 'depot' || p.type.toLowerCase() == 'entrant').toList();
                        final withdrawals = zonePayments.where((p) => p.type.toLowerCase() == 'retrait' || p.type.toLowerCase() == 'sortant').toList();

                        final totalDeposit = deposits.fold<double>(0, (sum, p) => sum + p.montant);
                        final totalWithdrawal = withdrawals.fold<double>(0, (sum, p) => sum + p.montant);

                        return Column(
                          children: [
                            const Divider(color: Color(0xFF866900)),
                            const SizedBox(height: 12),
                            _buildStatRow('Utilisateurs', 'Admin: $admins', 'Agent: $agents', 'Cotisant: $cotisants'),
                            const SizedBox(height: 8),
                            _buildStatRow('Tontines', 'Actives: $activeTontines', 'Inactives: $inactiveTontines', ''),
                            const SizedBox(height: 8),
                            _buildStatRow('Finances', 'Dépôts: ${totalDeposit.toStringAsFixed(0)} CFA', 'Retraits: ${totalWithdrawal.toStringAsFixed(0)} CFA', ''),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value1, String value2, String value3) {
    return Row(
      children: [
        Container(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF866900),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value1,
            style: const TextStyle(color: Color(0xFF2C2410)),
          ),
        ),
        if (value2.isNotEmpty) Expanded(
          child: Text(
            value2,
            style: const TextStyle(color: Color(0xFF2C2410)),
          ),
        ),
        if (value3.isNotEmpty) Expanded(
          child: Text(
            value3,
            style: const TextStyle(color: Color(0xFF2C2410)),
          ),
        ),
      ],
    );
  }
}
