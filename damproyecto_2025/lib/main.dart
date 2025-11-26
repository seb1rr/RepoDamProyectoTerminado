import 'package:damproyecto_2025/auth/auth.dart';
import 'package:damproyecto_2025/utils/constantes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('es')],
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: kColorMorado)),
      home: const AuthGate(),
    );
  }
}
