import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:damproyecto_2025/utils/constantes.dart';

class DetalleEventoPage extends StatelessWidget {
  // ID del evento que se quiere mostrar
  final String id;

  const DetalleEventoPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle del Evento"), backgroundColor: kColorMorado, foregroundColor: Colors.white),

      // Se obtiene el evento desde Firestore usando su ID
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("eventos").doc(id).get(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Datos del evento obtenidos desde Firestore
          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Se extraen los campos principales del evento
          final titulo = data["titulo"];
          final lugar = data["lugar"];
          final categoriaID = data["categoria"];
          final autor = data["autor"];

          // Conversión de Timestamp a DateTime
          Timestamp ts = data["fechaHora"];
          DateTime fecha = ts.toDate();

          // Formato de fecha usando intl
          String fechaTexto = DateFormat('dd/MM/yyyy HH:mm', 'es').format(fecha);

          // Se obtiene la categoría usando el ID guardado en el evento
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection("categorias").doc(categoriaID).get(),

            builder: (context, catSnap) {
              // Mientras se carga la categoría
              if (!catSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // Datos de la categoría
              final categoria = catSnap.data!.data() as Map<String, dynamic>;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen asociada a la categoría del evento
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset("assets/images/" + categoria["foto"], height: 180, width: 180, fit: BoxFit.cover),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Título del evento
                    Text(
                      titulo,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kColorMorado),
                    ),

                    const SizedBox(height: 20),

                    // Información detallada del evento
                    Text("Categoría: " + categoria["nombre"], style: const TextStyle(fontSize: 18)),
                    Text("Fecha: " + fechaTexto, style: const TextStyle(fontSize: 18)),
                    Text("Lugar: " + lugar, style: const TextStyle(fontSize: 18)),
                    Text("Autor: " + autor, style: const TextStyle(fontSize: 18)),

                    const SizedBox(height: 40),

                    // Botón para eliminar el evento
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text("Eliminar evento"),
                        style: ElevatedButton.styleFrom(backgroundColor: kColorAzul, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: () async {
                          // Borra el evento en Firestore
                          await FirebaseFirestore.instance.collection("eventos").doc(id).delete();

                          // Vuelve a la pantalla anterior
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
