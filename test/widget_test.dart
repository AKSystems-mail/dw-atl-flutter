import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';

void main() {
  testWidgets('Product list smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DopeWarsAtlanta());

    // Verify that the product list contains the expected items.
    expect(find.text('Blunts/Pre Rolls'), findsOneWidget);
    expect(find.text('Oxy'), findsOneWidget);
    expect(find.text('Shrooms'), findsOneWidget);
    expect(find.text('Powda'), findsOneWidget);
    expect(find.text('Acid'), findsOneWidget);
  });
}