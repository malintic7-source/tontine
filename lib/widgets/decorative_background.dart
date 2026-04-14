import 'package:flutter/material.dart';

/// Couleurs DiagoTono
abstract final class _Brand {
  static const Color primaryLight = Color(0xFFFFC800);
  static const Color cardLight = Colors.white24;
  static const Color white = Colors.white;
}

class DecorativeBackground extends StatelessWidget {
  const DecorativeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Grand cercle en haut à droite
          Positioned(
            right: -80,
            top: -40,
            child: Container(
              width: 200,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _Brand.cardLight,
                boxShadow: [
                  BoxShadow(
                    color: _Brand.white.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
          // Cercle moyen en haut à gauche
          Positioned(
            left: 60,
            top: 120,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _Brand.cardLight,
                boxShadow: [
                  BoxShadow(
                    color: _Brand.white.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          // Petit cercle jaune en haut à droite
          Positioned(
            right: 120,
            top: 250,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _Brand.primaryLight.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: _Brand.primaryLight.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          // Grand cercle jaune en bas à gauche
          Positioned(
            left: -40,
            bottom: 120,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _Brand.primaryLight.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow[200]!.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
          // Petit cercle en bas à droite
          Positioned(
            right: 40,
            bottom: 200,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _Brand.cardLight,
                boxShadow: [
                  BoxShadow(
                    color: _Brand.white.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          // Cercle moyen en bas au centre
          Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _Brand.primaryLight.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: _Brand.primaryLight.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
