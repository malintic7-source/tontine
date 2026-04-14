import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF866900),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 100,
                  ),
                  child: SingleChildScrollView(
                    child: Center(
                      child: SizedBox(
                        width:
                            MediaQuery.of(context).size.width >=
                                MediaQuery.of(context).size.height
                            ? MediaQuery.of(context).size.width / 3
                            : MediaQuery.of(context).size.width / 1.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),
                            Container(
                              height: 120,
                              width: 120,
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
                                    height: 120,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Bienvenue sur DiagoTono',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Connectez-vous pour piloter vos tontines, paiements et utilisateurs.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 50,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _emailController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white24,
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                      hintText: 'Entrez votre email',
                                      hintStyle: TextStyle(
                                        color: Colors.white54,
                                      ),
                                      labelText: 'Email',
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Color(0xFFFFC800),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    style: const TextStyle(color: Colors.white),
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white24,
                                      prefixIcon: Icon(
                                        Icons.password,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                      hintText: 'Entrez votre mot de passe',
                                      hintStyle: TextStyle(
                                        color: Colors.white54,
                                      ),
                                      labelText: 'Mot de passe',
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Color(0xFFFFC800),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 12),
                                  if (_error != null)
                                    Text(
                                      _error!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      fixedSize: Size(
                                        MediaQuery.of(context).size.width >=
                                                MediaQuery.of(
                                                  context,
                                                ).size.height
                                            ? MediaQuery.of(
                                                    context,
                                                  ).size.width /
                                                  3
                                            : MediaQuery.of(
                                                    context,
                                                  ).size.width /
                                                  1.2,
                                        50,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _isLoading ? null : _signIn,
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            'Se connecter',
                                            style: TextStyle(
                                              color: Color(0xFF866900),
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Les comptes sont créés par l\'administrateur ou un agent autorisé. Si vous êtes un membre, contactez votre administrateur.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(0xFFFEF2C5)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height:
                      MediaQuery.of(context).size.width >=
                          MediaQuery.of(context).size.height
                      ? 50
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  height:
                      MediaQuery.of(context).size.width >=
                          MediaQuery.of(context).size.height
                      ? 150
                      : 70,
                  color: Colors.black54,
                  child:
                      MediaQuery.of(context).size.width >=
                          MediaQuery.of(context).size.height
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Logo
                                Image.asset(
                                  'assets/logo2.png',
                                  width: 45,
                                  height: 45,
                                ),
                                Text(
                                  'DiagoTono',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                Text(
                                  '© 2024 DiagoTono. Tous droits réservés.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            VerticalDivider(color: Colors.grey),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //Contact
                                Text(
                                  'Nos Contacts',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => (),
                                  child: Text(
                                    '+223 70 00 00 00',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => (),
                                  child: Text(
                                    '+223 70 00 00 00',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => (),
                                  child: Text(
                                    'malintic@gmail.com',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                            VerticalDivider(color: Colors.grey),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //Liens utils
                                Text(
                                  'Liens utiles',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => (),
                                  child: Text(
                                    'Politique de confidentialité',

                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.white70,
                                      decorationColor: Colors.white70,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => (),
                                  child: Text(
                                    'Conditions d\'utilisation',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white70,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const Center(
                          child: Text(
                            '© 2024 DiagoTono. Tous droits réservés.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -50,
            top: -20,
            child: Container(
              width: 150,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 50,
            top: 100,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 100,
            top: 225,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 150,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow[200]!,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
    
        ],
      ),
    );
  }
}
