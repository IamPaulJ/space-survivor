import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/season_pass/providers/season_pass_provider.dart';
import 'features/season_pass/screens/season_pass_screen.dart';
import 'features/season_pass/services/season_pass_service.dart';

void main() {
  runApp(const SpaceSurvivorApp());
}

class SpaceSurvivorApp extends StatelessWidget {
  const SpaceSurvivorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SeasonPassProvider(SeasonPassService())..init(),
        ),
      ],
      child: MaterialApp(
        title: 'Space Survivor',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0A0A1A),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7B68EE),
            secondary: Color(0xFFFFD700),
          ),
        ),
        home: const SeasonPassScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
