import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:damproyecto_2025/services/eventosservice.dart';
import 'package:damproyecto_2025/services/categoriasservice.dart';
import 'package:damproyecto_2025/utils/constantes.dart';

class CrearEventoPage extends StatefulWidget {
  const CrearEventoPage({super.key});

  @override
  State<CrearEventoPage> createState() => _CrearEventoPageState();
}

class _CrearEventoPageState extends State<CrearEventoPage> {
  final formKey = GlobalKey<FormState>();

  TextEditingController tituloCtrl = TextEditingController();
  TextEditingController lugarCtrl = TextEditingController();

  DateTime? fechaSeleccionada;
  String? categoriaSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear evento"), backgroundColor: kColorMorado, foregroundColor: Colors.white),

      body: Container(
        padding: const EdgeInsets.all(12),

        child: Form(
          key: formKey,
          child: ListView(
            children: [
              // TITULO
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextFormField(
                  controller: tituloCtrl,
                  decoration: const InputDecoration(labelText: "Título del evento"),
                  validator: (v) => v!.isEmpty ? "Ingrese título" : null,
                ),
              ),

              // FECHA (MEJORADA VISUALMENTE)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: kColorAzul),
                  title: Text(
                    fechaSeleccionada == null
                        ? "Seleccionar fecha"
                        : "${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year} "
                              "${fechaSeleccionada!.hour}:${fechaSeleccionada!.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(color: fechaSeleccionada == null ? Colors.grey : kColorNegro),
                  ),
                  onTap: () async {
                    final fecha = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));

                    if (fecha == null) return;

                    final hora = await showTimePicker(context: context, initialTime: TimeOfDay.now());

                    if (hora == null) return;

                    setState(() {
                      fechaSeleccionada = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
                    });
                  },
                ),
              ),

              // LUGAR
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextFormField(
                  controller: lugarCtrl,
                  decoration: const InputDecoration(labelText: "Lugar"),
                  validator: (v) => v!.isEmpty ? "Ingrese lugar" : null,
                ),
              ),

              // CATEGORIAS
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: StreamBuilder<QuerySnapshot>(
                  stream: CategoriasService().listarCategorias(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text("Cargando categorías...");
                    }

                    return DropdownButtonFormField<String>(
                      value: categoriaSeleccionada,
                      decoration: const InputDecoration(labelText: "Categoría"),
                      items: snapshot.data!.docs.map((doc) {
                        final cat = doc.data() as Map<String, dynamic>;
                        return DropdownMenuItem(value: doc.id, child: Text(cat["nombre"]));
                      }).toList(),
                      validator: (v) => v == null ? "Seleccione categoría" : null,
                      onChanged: (v) {
                        categoriaSeleccionada = v;
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // BOTON GUARDAR
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: kColorAzul),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  if (fechaSeleccionada == null) return;

                  await EventosService().crearEvento(tituloCtrl.text.trim(), Timestamp.fromDate(fechaSeleccionada!), lugarCtrl.text.trim(), categoriaSeleccionada!, FirebaseAuth.instance.currentUser!.email!);

                  Navigator.pop(context);
                },
                child: const Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
