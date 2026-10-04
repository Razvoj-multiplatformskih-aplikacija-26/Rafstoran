import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';

void main() {
  testWidgets('shows free slots on the home screen', (tester) async {
    await tester.pumpWidget(const RafstoranApp());
    await tester.pumpAndSettle();

    expect(find.text('Rezervišite sto'), findsOneWidget);
    expect(find.text('Danas'), findsOneWidget);
  });
}
