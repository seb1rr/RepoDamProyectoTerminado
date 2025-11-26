import 'package:damproyecto_2025/services/categoriasservice.dart';
import 'package:damproyecto_2025/services/eventosservice.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrearEventoPage extends StatefulWidget {
  const CrearEventoPage({super.key});

  @override
  State<CrearEventoPage> createState() => _CrearEventoPageState();
}

class _CrearEventoPageState extends State<CrearEventoPage> {
  final _formKey = GlobalKey<FormState>();

  final _tituloCtrl = TextEditingController();
  final _lugarCtrl = TextEditingController();

  DateTime? fechaSeleccionada;

  // servicio de eventos
  final EventosService _service = EventosService();

  // servicio de categorías
  final CategoriasService _categoriasService = CategoriasService();

  // categoría seleccionada (ID del documento)
  String? categoriaSeleccionada;

  Future<void> _seleccionarFecha(BuildContext context) async {
    final fecha = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: DateTime.now());

    if (fecha == null) return;

    final hora = await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (hora == null) return;

    setState(() {
      fechaSeleccionada = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Evento")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Titulo
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(labelText: "Título"),
                validator: (v) => v!.isEmpty ? "Ingrese título" : null,
              ),
              const SizedBox(height: 15),

              // Fecha
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: Text(
                  fechaSeleccionada == null
                      ? "Seleccionar fecha y hora"
                      : "${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year} "
                            "${fechaSeleccionada!.hour}:${fechaSeleccionada!.minute.toString().padLeft(2, '0')}",
                ),
                onTap: () => _seleccionarFecha(context),
              ),

              const SizedBox(height: 20),

              // Categoría desde Firebase
              StreamBuilder<QuerySnapshot>(
                stream: _categoriasService.listarCategorias(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final categorias = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Categoría"),
                    value: categoriaSeleccionada,
                    items: categorias.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id, // 👈 guardamos ID de la categoría
                        child: Text(data["nombre"]),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        categoriaSeleccionada = value;
                      });
                    },
                    validator: (v) => v == null ? "Seleccione una categoría" : null,
                  );
                },
              ),

              const SizedBox(height: 20),

              // Lugar
              TextFormField(
                controller: _lugarCtrl,
                decoration: const InputDecoration(labelText: "Lugar"),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && fechaSeleccionada != null) {
                    final user = FirebaseAuth.instance.currentUser!;

                    await _service.crearEvento(
                      _tituloCtrl.text,
                      Timestamp.fromDate(fechaSeleccionada!),
                      _lugarCtrl.text,
                      categoriaSeleccionada!, // 👈 guardamos ID, no texto
                      user.email!,
                    );

                    Navigator.pop(context);
                  }
                },
                child: const Text("Guardar Evento"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
