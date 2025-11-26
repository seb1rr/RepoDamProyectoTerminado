import 'package:damproyecto_2025/services/loginservice.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text("Ingresar con Google", style: TextStyle(fontSize: 16)),
          onPressed: () async {
            await _authService.signInWithGoogle();
          },
        ),
      ),
    );
  }
}
