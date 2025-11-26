import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:damproyecto_2025/pages/detalleevento.dart';
import 'package:damproyecto_2025/services/eventosservice.dart';
import 'package:damproyecto_2025/utils/constantes.dart';

class ListarEventosPage extends StatelessWidget {
  ListarEventosPage({super.key});

  final EventosService _eventosService = EventosService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lista de eventos"), backgroundColor: kColorMorado, foregroundColor: Colors.white),

      body: StreamBuilder<QuerySnapshot>(
        stream: _eventosService.listarEventos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No hay eventos publicados.", style: TextStyle(color: kColorNegro)),
            );
          }

          return ListView.separated(
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),

            itemBuilder: (context, index) {
              final evento = snapshot.data!.docs[index];
              final data = evento.data() as Map<String, dynamic>;

              final titulo = data['titulo'];
              final lugar = data['lugar'];
              final categoriaID = data['categoria'];

              Timestamp ts = data['fechaHora'];
              DateTime fecha = ts.toDate();

              String fechaTexto = DateFormat('dd/MM/yyyy HH:mm', 'es').format(fecha);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection("categorias").doc(categoriaID).get(),
                builder: (context, catSnap) {
                  if (!catSnap.hasData) {
                    return const ListTile(title: Text("Cargando categoría..."));
                  }

                  final categoria = catSnap.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: const Icon(Icons.event, color: kColorAzul),

                    title: Text(
                      titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: kColorMorado),
                    ),

                    subtitle: Text(categoria["nombre"] + " · " + fechaTexto + " · " + lugar, style: const TextStyle(color: kColorNegro)),

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
