import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tontine/widgets/decorative_background.dart';
import '../screens/payments_screen.dart';
import '../screens/tontines_screen.dart';
import '../screens/users_screen.dart';
import '../screens/zones_screen.dart';
import 'app_drawer.dart';

/// Couleurs DiagoTono
abstract final class _Brand {
  static const Color primary = Color(0xFF866900);
  static const Color primaryLight = Color(0xFFFFC800);
  static const Color primaryDark = Color(0xFF5C4706);
  static const Color card = Color(0xFFFFF6E0);
  static const Color cardLight = Colors.white24;
  static const Color ink = Color(0xFF2C2410);
  static const Color muted = Color(0xFF6B5E45);
  static const Color white = Colors.white;
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String route;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.route,
  });
}

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final int selectedIndex;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    required this.selectedIndex,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;

  final List<_MenuItem> _menuItems = [
    _MenuItem(
      icon: Icons.dashboard,
      title: 'Tableau de bord',
      route: '/dashboard',
    ),
    _MenuItem(
      icon: Icons.location_on,
      title: 'Zones',
      route: ZonesScreen.routeName,
    ),
    _MenuItem(
      icon: Icons.groups,
      title: 'Tontines',
      route: TontinesScreen.routeName,
    ),
    _MenuItem(
      icon: Icons.payment,
      title: 'Paiements',
      route: PaymentsScreen.routeName,
    ),
    _MenuItem(
      icon: Icons.person,
      title: 'Utilisateurs',
      route: UsersScreen.routeName,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (ModalRoute.of(context)?.settings.name != _menuItems[index].route) {
      Navigator.pushNamed(context, _menuItems[index].route);
    }
  }

  Future<void> _showSignOutDialog() async {
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
              color: _Brand.primary,
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
            child: Text(
              'Annuler',
              style: TextStyle(
                color: _Brand.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _Brand.primary,
              foregroundColor: _Brand.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await FirebaseAuth.instance.signOut();
              if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 800;

    if (isDesktop) {
      return _buildDesktopLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: _Brand.primary,
      body: Row(
        children: [
          _Sidebar(
            menuItems: _menuItems,
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            userEmail: user?.email,
            onSignOut: _showSignOutDialog,
          ),
          Expanded(
            child: Stack(
              children: [
                _buildMainContent(),
                _buildDecorativeCircles(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: _Brand.primary,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: _Brand.primary,
        elevation: 0,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          _buildMainContent(),
          _buildDecorativeCircles(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        Expanded(
          child: widget.child,
        ),
        const _Footer(),
      ],
    );
  }

  Widget _buildDecorativeCircles() {
    return const DecorativeBackground();
  }
}

class _Sidebar extends StatelessWidget {
  final List<_MenuItem> menuItems;
  final int selectedIndex;
  final Function(int) onItemTapped;
  final String? userEmail;
  final VoidCallback onSignOut;

  const _Sidebar({
    required this.menuItems,
    required this.selectedIndex,
    required this.onItemTapped,
    this.userEmail,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: _Brand.primaryDark,
        border: Border(
          right: BorderSide(
            color: _Brand.primaryLight,
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: _Brand.white,
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _Brand.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail ?? 'Utilisateur',
                  style: TextStyle(
                    fontSize: 12,
                    color: _Brand.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: _Brand.primaryLight, height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return _SidebarItem(
                  icon: menuItems[index].icon,
                  title: menuItems[index].title,
                  isSelected: isSelected,
                  onTap: () => onItemTapped(index),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: _SidebarItem(
              icon: Icons.logout,
              title: 'Se déconnecter',
              isSelected: false,
              onTap: onSignOut,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _Brand.primaryLight.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _Brand.primaryLight : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? _Brand.primaryLight : _Brand.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? _Brand.primaryLight : _Brand.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 800;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16, vertical: 16),
      color: Colors.black54,
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Image.asset(
                              'assets/logo2.png',
                              width: 45,
                              height: 45,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: const Text(
                              'DiagoTono',
                              style: TextStyle(
                                color: _Brand.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '© 2024 DiagoTono. Tous droits réservés.',
                        style: TextStyle(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(color: Colors.grey),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Nos Contacts',
                        style: TextStyle(
                          color: _Brand.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          '+223 70 00 00 00',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          'malintic@gmail.com',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(color: Colors.grey),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Liens utiles',
                        style: TextStyle(
                          color: _Brand.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          'Politique de confidentialité',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.white70,
                            decorationColor: Colors.white70,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          "Conditions d'utilisation",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white70,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: Text(
                '© 2024 DiagoTono. Tous droits réservés.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
    );
  }
}
