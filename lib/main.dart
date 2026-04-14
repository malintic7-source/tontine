import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/payments_screen.dart';
import 'screens/tontines_screen.dart';
import 'screens/users_screen.dart';
import 'screens/zones_screen.dart';
import 'package:tontine/services/firestore_service.dart';
import 'package:tontine/models/app_user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyD-OoHd9FzaulpkYnfr-EczVbbbB_DQn5M',
      authDomain: 'mali-ntic.firebaseapp.com',
      projectId: 'mali-ntic',
      storageBucket: 'mali-ntic.firebasestorage.app',
      messagingSenderId: '90700237324',
      appId: '1:90700237324:web:f5c951d986d9d5d3f37c29',
      measurementId: 'G-QM4NXNZ43J',
    ),
  );
  runApp(TontineApp());
}

class TontineApp extends StatelessWidget {
  const TontineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiagoTono',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF8B6D0A),
        scaffoldBackgroundColor: const Color(0xFFF7ECD0),
        canvasColor: const Color(0xFF8B6D0A),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.amber,
          backgroundColor: const Color(0xFFF7ECD0),
          cardColor: const Color(0xFFFFF6E0),
        ).copyWith(secondary: const Color(0xFFD9AF00)),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF8B6D0A),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      home: AuthGate(),
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        DashboardScreen.routeName: (context) => const DashboardScreen(),
        ZonesScreen.routeName: (context) => ZonesScreen(),
        TontinesScreen.routeName: (context) => TontinesScreen(),
        PaymentsScreen.routeName: (context) => PaymentsScreen(),
        UsersScreen.routeName: (context) => UsersScreen(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  final FirestoreService _service = FirestoreService();

  AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData) {
          return LoginScreen();
        }

        return FutureBuilder<AppUser?>(
          future: _service.getUtilisateurByUid(snapshot.data!.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final appUser = roleSnapshot.data;
            final userEmail = snapshot.data!.email;

            // Special admin access for docbackup72@gmail.com
            if (userEmail == 'docbackup72@gmail.com') {
              return const DashboardScreen();
            }

            if (appUser == null) {
              return _buildAccessDenied(
                context,
                'Votre compte n\'est pas enregistré comme agent ou administrateur.',
              );
            }
            final role = appUser.role.toLowerCase();
            if (role == 'admin' || role == 'agent') {
              return const DashboardScreen();
            }
            return _buildAccessDenied(
              context,
              'Vous n\'avez pas les droits nécessaires pour accéder à l\'application.',
            );
          },
        );
      },
    );
  }

  Widget _buildAccessDenied(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accès refusé'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, color: Colors.purple, size: 72),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                child: const Text('Retour à la connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
