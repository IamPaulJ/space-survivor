import 'package:flutter/material.dart';

void main() {
  runApp(const SpaceSurvivorApp());
}

class SpaceSurvivorApp extends StatelessWidget {
  const SpaceSurvivorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Survivor',
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: Center(child: Text('Space Survivor')),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
