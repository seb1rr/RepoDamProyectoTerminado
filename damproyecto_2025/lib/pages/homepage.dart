import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:damproyecto_2025/services/loginservice.dart';

import 'creareventopage.dart';
import 'listareventos.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Proyecto DAM"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Bienvenido, ${user?.displayName ?? user?.email ?? 'Usuario'}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Crear Evento", style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CrearEventoPage()));
                  },
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.list),
                  label: const Text("Listar Eventos", style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ListarEventosPage()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
