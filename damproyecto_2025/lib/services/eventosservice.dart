import 'package:cloud_firestore/cloud_firestore.dart';

class EventosService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> listarEventos() {
    return _db.collection("eventos").orderBy("fechaHora").snapshots();
  }

  Future<void> crearEvento(String titulo, Timestamp fechaHora, String lugar, String categoria, String autor) async {
    await _db.collection("eventos").add({"titulo": titulo, "fechaHora": fechaHora, "lugar": lugar, "categoria": categoria, "autor": autor});
  }

  Future<void> borrarEvento(String id) async {
    await _db.collection("eventos").doc(id).delete();
  }
}
