import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:creatorpilot/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: CreatorPilotApp()),
    );

    // Verify the app renders (splash screen should appear)
    expect(find.text('CreatorPilot'), findsOneWidget);
  });
}
