import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_super_app/main.dart';

void main() {
  testWidgets('Super App bottom navigation smoke test', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the Home Screen welcome text is displayed.
    expect(find.text('Good Morning, Alex'), findsOneWidget);
    expect(find.text('Discovery Hub'), findsNothing);
    expect(find.text('Auto Store'), findsNothing);
    expect(find.text('Fintech Wallet'), findsNothing);
    expect(find.text('Profile Dashboard'), findsNothing);

    // Tap the 'Explore' tab and trigger frame transition.
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();

    // Verify that the Explore Screen title is now visible.
    expect(find.text('Discovery Hub'), findsOneWidget);
    expect(find.text('Good Morning, Alex'), findsNothing);

    // Tap the 'Store' tab and trigger a frame transition.
    await tester.tap(find.text('Store'));
    await tester.pumpAndSettle();

    // Verify that the Store Screen title is now visible.
    expect(find.text('Auto Store'), findsOneWidget);

    // Tap the 'News' tab and trigger frame transition.
    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();

    // Verify that the News Screen title is now visible.
    expect(find.text('Ecosystem News'), findsOneWidget);

    // Tap the 'Profile' tab and trigger frame transition.
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Verify that the Profile Screen title is now visible.
    expect(find.text('Profile Dashboard'), findsOneWidget);
  });
}
