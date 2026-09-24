import 'package:flutter_test/flutter_test.dart';

import 'package:petcare/main.dart';

void main() {
  testWidgets('PetCare inicia corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const PetCareApp());

    expect(find.text('PetCare'), findsOneWidget);
    expect(find.text('Cuidar também é amar. 🐾'), findsOneWidget);
  });
}
