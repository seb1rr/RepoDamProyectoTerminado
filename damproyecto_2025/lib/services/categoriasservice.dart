import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriasService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> listarCategorias() {
    return _db.collection("categorias").snapshots();
  }
}
