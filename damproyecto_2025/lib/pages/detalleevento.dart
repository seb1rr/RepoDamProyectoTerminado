import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetalleEventoPage extends StatelessWidget {
  final String id;

  const DetalleEventoPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle del Evento")),
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
          final Timestamp fechaTS = data["fechaHora"];
          final fecha = fechaTS.toDate();
          final autor = data["autor"];

          final fechaTexto =
              "${fecha.day}/${fecha.month}/${fecha.year} "
              "a las ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";

          // Ahora obtenemos la categoría del evento
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection("categorias").doc(categoriaID).get(),
            builder: (context, catSnap) {
              if (!catSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final catData = catSnap.data!.data() as Map<String, dynamic>;
              final nombreCat = catData["nombre"];
              final fotoCat = catData["foto"]; // ← imagen de la categoría

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ⭐ FOTO GRANDE DE LA CATEGORÍA ⭐
                    Center(
                      child: ClipRRect(borderRadius: BorderRadius.circular(15), child: _buildCategoriaImage(fotoCat)),
                    ),

                    const SizedBox(height: 30),

                    // ⭐ TÍTULO ⭐
                    Text(titulo, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),

                    const SizedBox(height: 20),

                    // ⭐ DETALLES ⭐
                    _detalle("Categoría", nombreCat),
                    _detalle("Fecha", fechaTexto),
                    _detalle("Lugar", lugar),
                    _detalle("Autor", autor),

                    const SizedBox(height: 40),

                    // ⭐ BORRAR EVENTO ⭐
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text("Eliminar evento"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection("eventos").doc(id).delete();

                          Navigator.pop(context); // vuelve al listado
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

  /// 🔹 Construye un texto bonito de detalle
  Widget _detalle(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text("$label: $valor", style: const TextStyle(fontSize: 18)),
    );
  }

  /// 🔥 Muestra la imagen de categoría (assets o URL)
  Widget _buildCategoriaImage(String foto) {
    // Caso 1: es una URL (Firebase Storage)
    if (foto.startsWith("http")) {
      return Image.network(foto, height: 180, width: 180, fit: BoxFit.cover);
    }

    // Caso 2: es imagen de assets
    return Image.asset("assets/images/$foto", height: 180, width: 180, fit: BoxFit.cover);
  }
}
