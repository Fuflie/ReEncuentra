import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:typed_data';

class FSService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<QuerySnapshot> obtenerCategorias() {
    return db.collection('categorias').get();
  }

  Stream<QuerySnapshot> obtenerPublicaciones() {
    return db.collection('publicaciones').snapshots();
  }

  Stream<QuerySnapshot> obtenerMisPublicaciones() {
    final usuario = FirebaseAuth.instance.currentUser!;

    return db
        .collection('publicaciones')
        .where('autorId', isEqualTo: usuario.uid)
        .snapshots();
  }

  Future<void> agregarPublicacion(
    String titulo,
    String descripcion,
    String tipo,
    String categoria,
    String lugar,
    DateTime fecha,
    Uint8List foto,
  ) async {
    final usuario = FirebaseAuth.instance.currentUser!;

    await db.collection('publicaciones').doc().set({
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'categoria': categoria,
      'lugar': lugar,
      'fecha': Timestamp.fromDate(fecha),
      'foto': Blob(foto),
      'estado': 'Vigente',
      'autorId': usuario.uid,
      'autorNombre': usuario.displayName ?? 'Usuario',
    });
  }

  Future<void> marcarDevuelto(String id) async {
    await db.collection('publicaciones').doc(id).update({'estado': 'Devuelto'});
  }

  Future<void> eliminarPublicacion(String id) async {
    await db.collection('publicaciones').doc(id).delete();
  }
}
