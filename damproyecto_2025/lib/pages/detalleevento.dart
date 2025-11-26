import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:damproyecto_2025/utils/constantes.dart';

class DetalleEventoPage extends StatelessWidget {
  final String id;

  const DetalleEventoPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle del Evento"), backgroundColor: kColorMorado, foregroundColor: Colors.white),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("eventos").doc(id).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final titulo = data["titulo"];
          final lugar = data["lugar"];
          final categoriaID = data["categoria"];
          final autor = data["autor"];

          Timestamp ts = data["fechaHora"];
          DateTime fecha = ts.toDate();

          String fechaTexto = DateFormat('dd/MM/yyyy HH:mm', 'es').format(fecha);

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection("categorias").doc(categoriaID).get(),
            builder: (context, catSnap) {
              if (!catSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final categoria = catSnap.data!.data() as Map<String, dynamic>;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset("assets/images/" + categoria["foto"], height: 180, width: 180, fit: BoxFit.cover),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      titulo,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kColorMorado),
                    ),

                    const SizedBox(height: 20),

                    Text("Categoría: " + categoria["nombre"], style: const TextStyle(fontSize: 18)),
                    Text("Fecha: " + fechaTexto, style: const TextStyle(fontSize: 18)),
                    Text("Lugar: " + lugar, style: const TextStyle(fontSize: 18)),
                    Text("Autor: " + autor, style: const TextStyle(fontSize: 18)),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text("Eliminar evento"),
                        style: ElevatedButton.styleFrom(backgroundColor: kColorAzul, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection("eventos").doc(id).delete();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
