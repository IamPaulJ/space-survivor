import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_survivor/features/season_pass/providers/season_pass_provider.dart';
import 'package:space_survivor/features/season_pass/screens/season_pass_screen.dart';
import 'package:space_survivor/features/season_pass/services/season_pass_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SeasonPassScreen shows loading then content', (WidgetTester tester) async {
    final provider = SeasonPassProvider(SeasonPassService());

    await tester.pumpWidget(
      ChangeNotifierProvider<SeasonPassProvider>.value(
        value: provider,
        child: const MaterialApp(home: SeasonPassScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await provider.init();
    await tester.pumpAndSettle();

    expect(find.text('Season Pass'), findsOneWidget);
    expect(find.text('Season 1'), findsOneWidget);
  });

  testWidgets('SeasonPassScreen shows premium banner when not premium', (WidgetTester tester) async {
    final provider = SeasonPassProvider(SeasonPassService());
    await provider.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<SeasonPassProvider>.value(
        value: provider,
        child: const MaterialApp(home: SeasonPassScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unlock Premium Pass'), findsOneWidget);
  });
}
