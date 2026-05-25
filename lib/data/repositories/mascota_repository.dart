import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/data/models/usuarios.dart';
import 'package:pawter/data/models/enums/rol_usuario.dart';

class MascotaRepository {
  final DatabaseReference _refBD = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://pawter-dgm96-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref();

  Future<List<Mascota>> obtenerMascotasPorDueno(String idUsuario) async {
    try {
      final respuestaBD = await _refBD.child('mascotas').child(idUsuario).get();
      if (respuestaBD.exists) {
        final Map<dynamic, dynamic> datos = respuestaBD.value as Map<dynamic, dynamic>;
        return datos.entries.map((entrada) {
          final resultado = Map<String, dynamic>.from(entrada.value as Map);
          if (resultado['id_mascota'] == null) {
            resultado['id_mascota'] = entrada.key;
          }
          return Mascota.fromJson(resultado);
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> guardarMascota(Mascota mascota, String idUsuario) async {
    try {
      await _refBD
          .child('mascotas')
          .child(idUsuario)
          .child(mascota.idMascota.toString())
          .set(mascota.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> actualizarFotoMascotaBD(
      String idUsuario, int idMascota, String nuevaUrl) async {
    try {
      await _refBD
          .child('mascotas')
          .child(idUsuario)
          .child(idMascota.toString())
          .update({'foto_url': nuevaUrl});
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> obtenerDatosMascota(
      String idUsuario, String idMascota) async {
    try {
      final respuestaBD = await _refBD
          .child('mascotas')
          .child(idUsuario)
          .child(idMascota)
          .get();
      if (respuestaBD.exists) {
        return Map<String, dynamic>.from(respuestaBD.value as Map);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerPacientesConDueno() async {
    try {
      final busquedaDBUsuarios = await _refBD.child('usuarios').get();
      Map<String, Usuario> clientes = {};

      if (busquedaDBUsuarios.exists) {
        final datosUsuarios =
            busquedaDBUsuarios.value as Map<dynamic, dynamic>;
        datosUsuarios.forEach((key, value) {
          final usu =
              Usuario.fromJson(Map<String, dynamic>.from(value as Map));
          if (usu.rol == RolUsuario.cliente) {
            clientes[key.toString()] = usu;
          }
        });
      }

      final busquedaDBpets = await _refBD.child('mascotas').get();
      List<Map<String, dynamic>> resultado = [];

      if (busquedaDBpets.exists) {
        final datosMascotas =
            busquedaDBpets.value as Map<dynamic, dynamic>;

        datosMascotas.forEach((idDueno, mascotasDelUsuario) {
          final idDuenoStr = idDueno.toString();
          if (clientes.containsKey(idDuenoStr)) {
            final usuario = clientes[idDuenoStr]!;
            final mascotas = mascotasDelUsuario as Map<dynamic, dynamic>;

            mascotas.forEach((idMascota, datos) {
              final mapaDato = Map<String, dynamic>.from(datos as Map);
              if (mapaDato['id_mascota'] == null) {
                mapaDato['id_mascota'] = idMascota;
              }
              final mascota = Mascota.fromJson(mapaDato);
              resultado.add({'mascota': mascota, 'dueno': usuario});
            });
          }
        });
      }
      return resultado;
    } catch (e) {
      return [];
    }
  }

 //flujo que me permite ver los cambios sobre las mascotas
  Stream<void> mascotaCambios() {
    return _refBD.child('mascotas').onValue.map((_) {});
  }
}