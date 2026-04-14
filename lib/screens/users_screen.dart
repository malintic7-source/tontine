import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_user.dart';
import '../models/zone_model.dart';
import '../services/firestore_service.dart';
import '../widgets/main_layout.dart';

class UsersScreen extends StatelessWidget {
  static const routeName = '/users';
  final FirestoreService _service = FirestoreService();

  UsersScreen({super.key});

  Future<void> _showAddUserDialog(BuildContext context) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nomController = TextEditingController();
    final contactController = TextEditingController();
    String? selectedZoneId;
    var selectedRole = 'cotisant';
    final roles = ['owner', 'admin', 'agent', 'cotisant'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                        'Ajouter un utilisateur',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF866900),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildStyledTextField(
                        controller: emailController,
                        label: 'Email',
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 16),
                      _buildStyledTextField(
                        controller: passwordController,
                        label: 'Mot de passe',
                        icon: Icons.lock,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      _buildStyledTextField(
                        controller: nomController,
                        label: 'Nom complet',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),
                      _buildStyledTextField(
                        controller: contactController,
                        label: 'Contact',
                        icon: Icons.phone,
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
                      _buildRoleDropdown(
                        selectedRole: selectedRole,
                        roles: roles,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedRole = value;
                            });
                          }
                        },
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
                              if (emailController.text.trim().isEmpty ||
                                  passwordController.text.trim().isEmpty ||
                                  nomController.text.trim().isEmpty ||
                                  contactController.text.trim().isEmpty ||
                                  selectedZoneId == null)
                                return;
                              final navigator = Navigator.of(context);
                              try {
                                final credential = await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                    );
                                final user = credential.user;
                                if (user != null) {
                                  await _service.addUtilisateur(
                                    AppUser(
                                      uid: user.uid,
                                      email: user.email ?? emailController.text.trim(),
                                      nom: nomController.text.trim(),
                                      contact: contactController.text.trim(),
                                      zoneID: selectedZoneId!,
                                      role: selectedRole,
                                      date: Timestamp.now(),
                                    ),
                                  );
                                }
                                navigator.pop();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
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
    bool obscureText = false,
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
        obscureText: obscureText,
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

  Widget _buildRoleDropdown({
    required String selectedRole,
    required List<String> roles,
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
          labelText: 'Rôle',
          labelStyle: const TextStyle(
            color: Color(0xFF866900),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.badge, color: Color(0xFF866900)),
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
            value: selectedRole,
            isExpanded: true,
            onChanged: onChanged,
            dropdownColor: Colors.white,
            style: const TextStyle(
              color: Color(0xFF2C2410),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            iconEnabledColor: const Color(0xFF866900),
            items: roles.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    role,
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
      title: 'Utilisateurs',
      selectedIndex: 4,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<List<AppUser>>(
              stream: _service.utilisateursStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erreur de chargement des utilisateurs'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!;
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
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: const Text(
                          'Utilisateurs actifs',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${users.length} comptes enregistrés'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: users.isEmpty
                          ? const Center(child: Text('Aucun utilisateur trouvé'))
                          : ListView.separated(
                              itemCount: users.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return _UserCard(
                                  user: user,
                                  service: _service,
                                  onEdit: () => _showEditUserDialog(context, user),
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
              onPressed: () => _showAddUserDialog(context),
              child: const Icon(Icons.add, color: Color(0xFF866900)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditUserDialog(BuildContext context, AppUser user) {
    final nomController = TextEditingController(text: user.nom);
    final contactController = TextEditingController(text: user.contact);
    String? selectedZoneId = user.zoneID;
    var selectedRole = user.role;
    final roles = ['owner', 'admin', 'agent', 'cotisant'];

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                        'Modifier l\'utilisateur',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF866900),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildStyledTextField(
                        controller: nomController,
                        label: 'Nom complet',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),
                      _buildStyledTextField(
                        controller: contactController,
                        label: 'Contact',
                        icon: Icons.phone,
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
                      _buildRoleDropdown(
                        selectedRole: selectedRole,
                        roles: roles,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedRole = value;
                            });
                          }
                        },
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
                              if (nomController.text.trim().isEmpty ||
                                  contactController.text.trim().isEmpty ||
                                  selectedZoneId == null)
                                return;
                              await FirebaseFirestore.instance
                                  .collection('utilisateurs')
                                  .doc(user.uid)
                                  .update({
                                'nom': nomController.text.trim(),
                                'contact': contactController.text.trim(),
                                'zoneID': selectedZoneId,
                                'role': selectedRole,
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
}

class _UserCard extends StatelessWidget {
  final AppUser user;
  final FirestoreService service;
  final VoidCallback onEdit;

  const _UserCard({
    required this.user,
    required this.service,
    required this.onEdit,
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
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nom.isNotEmpty ? user.nom : user.email,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF866900),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final Uri emailUri = Uri.parse('mailto:${user.email}');
                          if (await canLaunchUrl(emailUri)) {
                            await launchUrl(emailUri);
                          }
                        },
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.email,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF866900),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Color(0xFF866900), size: 16),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: user.email));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Email copié'),
                                    backgroundColor: Color(0xFF866900),
                                  ),
                                );
                              },
                              tooltip: 'Copier',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF866900)),
                  onPressed: onEdit,
                  tooltip: 'Modifier',
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<ZoneModel>>(
              stream: service.zonesStream(),
              builder: (context, zoneSnapshot) {
                if (!zoneSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final zones = zoneSnapshot.data!;
                final zone = zones.firstWhere(
                  (z) => z.id == user.zoneID,
                  orElse: () => ZoneModel(
                    id: '',
                    nom: 'Zone non trouvée',
                    date: Timestamp.now(),
                  ),
                );
                return Column(
                  children: [
                    const Divider(color: Color(0xFF866900)),
                    const SizedBox(height: 12),
                    _buildInfoRow(context, 'Rôle', user.role, showCopy: false),
                    const SizedBox(height: 8),
                    _buildInfoRow(context, 'Zone', zone.nom, copyValue: user.zoneID),
                    const SizedBox(height: 8),
                    _buildInfoRow(context, 'Contact', user.contact, isPhone: true),
                    const SizedBox(height: 8),
                    _buildInfoRow(context, 'Email', user.email, isEmail: true),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF866900)),
            const SizedBox(height: 12),
            const Text(
              'Tontines',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF866900),
              ),
            ),
            const SizedBox(height: 8),
            if (user.tontines.isEmpty)
              const Text(
                'Aucune tontine',
                style: TextStyle(
                  color: Color(0xFF6B5E45),
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...user.tontines.map((tontine) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.group, color: Color(0xFF866900), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${tontine['id']}: ${tontine['montant']?.toString() ?? '0'} CFA',
                          style: const TextStyle(color: Color(0xFF2C2410)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isEmail = false, bool isPhone = false, bool showCopy = true, String? copyValue}) {
    return Row(
      children: [
        Container(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF866900),
            ),
          ),
        ),
        GestureDetector(
            onTap: () async {
              if (isEmail) {
                final Uri emailUri = Uri.parse('mailto:$value');
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              } else if (isPhone) {
                final Uri phoneUri = Uri.parse('tel:$value');
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                }
              }
            },
            child: Text(
              value,
              style: TextStyle(
                color: (isEmail || isPhone) ? const Color(0xFF866900) : const Color(0xFF2C2410),
                decoration: (isEmail || isPhone) ? TextDecoration.underline : null,
              ),
            ),
          ),
        if (showCopy)
          IconButton(
            icon: const Icon(Icons.copy, color: Color(0xFF866900), size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: copyValue ?? value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copié'),
                  backgroundColor: Color(0xFF866900),
                ),
              );
            },
            tooltip: 'Copier',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}
