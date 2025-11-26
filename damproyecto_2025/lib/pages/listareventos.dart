import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:damproyecto_2025/pages/detalleevento.dart';
import 'package:damproyecto_2025/services/eventosservice.dart';
import 'package:flutter/material.dart';

class ListarEventosPage extends StatelessWidget {
  ListarEventosPage({super.key});

  final EventosService _eventosService = EventosService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lista de eventos")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _eventosService.listarEventos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay eventos publicados."));
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final evento = docs[index];
              final data = evento.data() as Map<String, dynamic>;

              final titulo = data['titulo'] ?? 'Sin título';
              final lugar = data['lugar'] ?? '';
              final categoriaID = data['categoria'];

              final Timestamp fechaTS = data['fechaHora'];
              final fecha = fechaTS.toDate();

              final fechaTexto =
                  "${fecha.day}/${fecha.month}/${fecha.year} "
                  "${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection("categorias").doc(categoriaID).get(),
                builder: (context, catSnap) {
                  if (!catSnap.hasData) {
                    return const ListTile(title: Text("Cargando categoría..."));
                  }

                  final catData = catSnap.data!.data() as Map<String, dynamic>;
                  final nombreCat = catData["nombre"];

                  return ListTile(
                    title: Text(titulo),
                    subtitle: Text("$nombreCat · $fechaTexto · $lugar"),

                    // 🔥 NAVEGAR AL DETALLE
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DetalleEventoPage(id: evento.id)));
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
