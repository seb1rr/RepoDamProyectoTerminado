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
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _lugar = TextEditingController();

  DateTime? _fecha;
  String? _categoria;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear evento"), backgroundColor: kColorMorado, foregroundColor: Colors.white),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titulo,
              decoration: const InputDecoration(
                labelText: "Título",
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kColorMorado)),
              ),
              validator: (v) => v!.isEmpty ? "Ingrese título" : null,
            ),

            const SizedBox(height: 15),

            ListTile(
              leading: const Icon(Icons.calendar_today, color: kColorAzul),
              title: Text(
                _fecha == null
                    ? "Seleccionar fecha"
                    : "${_fecha!.day}/${_fecha!.month}/${_fecha!.year} "
                          "${_fecha!.hour}:${_fecha!.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(color: kColorNegro),
              ),
              onTap: () async {
                DateTime? f = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: DateTime.now());

                if (f == null) return;

                TimeOfDay? h = await showTimePicker(context: context, initialTime: TimeOfDay.now());

                if (h == null) return;

                setState(() {
                  _fecha = DateTime(f.year, f.month, f.day, h.hour, h.minute);
                });
              },
            ),

            const SizedBox(height: 20),

            StreamBuilder<QuerySnapshot>(
              stream: CategoriasService().listarCategorias(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Categoría",
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kColorMorado)),
                  ),
                  value: _categoria,
                  items: snapshot.data!.docs.map((doc) {
                    var cat = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(value: doc.id, child: Text(cat["nombre"]));
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      _categoria = v;
                    });
                  },
                  validator: (v) => v == null ? "Seleccione categoría" : null,
                );
              },
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _lugar,
              decoration: const InputDecoration(
                labelText: "Lugar",
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kColorMorado)),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kColorAzul, foregroundColor: Colors.white),
              onPressed: () async {
                if (_formKey.currentState!.validate() && _fecha != null) {
                  await EventosService().crearEvento(_titulo.text, Timestamp.fromDate(_fecha!), _lugar.text, _categoria!, FirebaseAuth.instance.currentUser!.email!);

                  Navigator.pop(context);
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
