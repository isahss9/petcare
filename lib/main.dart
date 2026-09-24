import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

void main() {
  runApp(const PetCareApp());
}

class PetCareApp extends StatelessWidget {
  const PetCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetCare',
      theme: AppTheme.lightTheme,
      home: const PetCareHomePage(),
    );
  }
}

class PetCareHomePage extends StatelessWidget {
  const PetCareHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PetCare')),

      body: Center(
        child: Text(
          'Cuidar também é amar. 🐾',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
