import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kulosehat/main.dart';

void main() {
  testWidgets('App shows landing page when no session exists', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('KuloSehat'), findsOneWidget);
    expect(find.text('Mulai Sekarang'), findsOneWidget);
  });
}
