import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String? userEmail;
  const AppDrawer({super.key, this.userEmail});

  Future<void> _showSignOutDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: const Color(0xFF866900),
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Déconnexion',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Annuler',
              style: TextStyle(
                color: Color(0xFF6B5E45),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF866900),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Se déconnecter',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFC800).withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFC800) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFFFC800) : Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFFC800) : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: Container(
        color: const Color(0xFF5C4706),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ClipRect(
                        child: Image.asset(
                          'assets/logo.png.png',
                          height: 100,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'DiagoTono',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? userEmail ?? 'Utilisateur',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFFFC800), height: 1),
            Expanded(
              child: Container(
                color: const Color(0xFF5C4706),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildItem(
                      context,
                      'Tableau de bord',
                      Icons.dashboard,
                      '/dashboard',
                      currentRoute == '/dashboard',
                    ),
                    _buildItem(
                      context,
                      'Zones',
                      Icons.location_on,
                      '/zones',
                      currentRoute == '/zones',
                    ),
                    _buildItem(
                      context,
                      'Tontines',
                      Icons.groups,
                      '/tontines',
                      currentRoute == '/tontines',
                    ),
                    _buildItem(
                      context,
                      'Paiements',
                      Icons.payment,
                      '/payments',
                      currentRoute == '/payments',
                    ),
                    _buildItem(
                      context,
                      'Utilisateurs',
                      Icons.person,
                      '/users',
                      currentRoute == '/users',
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFFFC800), height: 1),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: InkWell(
                        onTap: () => _showSignOutDialog(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Se déconnecter',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
