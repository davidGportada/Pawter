import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pawter/data/models/historial_clinico.dart';

class HistorialRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://pawter-dgm96-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref();

  Future<void> guardarRegistro(HistorialClinico registro) async {
    await _dbRef
        .child('historial_clinico')
        .child(registro.idMascota.toString())
        .child(registro.idRegistro.toString())
        .set(registro.toJson());
  }

  Future<List<HistorialClinico>> obtenerHistorial(int idMascota) async {
    try {
      final busquedaDB = await _dbRef.child('historial_clinico').child(idMascota.toString()).get();
      
      if (busquedaDB.exists) {
        final datos = busquedaDB.value;
        List<HistorialClinico> lista = [];

        //Por lo visto a veces firebase devuelve las cosas como maps o listas. prefiero controlar ambas que ya tuve unos errores por esto.
        if (datos is Map) {
          datos.forEach((key, value) {
            lista.add(HistorialClinico.fromJson(Map<String, dynamic>.from(value)));
          });
        } else if (datos is List) {
          for (var item in datos) {
            if (item != null) {
              lista.add(HistorialClinico.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
        lista.sort((a, b) => b.fecha.compareTo(a.fecha));
        return lista;
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}