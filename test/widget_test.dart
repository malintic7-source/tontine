import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tontine/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  testWidgets('affiche l\'écran de connexion sans utilisateur', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TontineApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Connexion Firebase'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });
}
