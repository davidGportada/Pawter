import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pawter/data/models/citas.dart';

class CitasRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://pawter-dgm96-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref();

  //Método que guarda la cita en FB, el viewmodel tendrá las restricciones necesarias dependiendo si es cliente o vet
  Future<void> guardarCita(Cita cita) async {
    try {
      String idCitaReal = cita.idCita;
      await _dbRef
          .child('citas')
          .child(cita.idCliente)
          .child(idCitaReal)
          .set(cita.toJson());

      String fechaKey ="${cita.fechaHora.year}-${cita.fechaHora.month.toString().padLeft(2, '0')}-${cita.fechaHora.day.toString().padLeft(2, '0')}";
      await _dbRef.child('agenda_global').child(fechaKey).child(idCitaReal).set({
        'id_cita': idCitaReal,
        'hora': "${cita.fechaHora.hour.toString().padLeft(2, '0')}:${cita.fechaHora.minute.toString().padLeft(2, '0')}",
        'id_cliente': cita.idCliente,
        'id_mascota': cita.idMascota.toString(),
        'motivo': cita.motivo,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Cita>> getCitasCliente(String idCliente) async {
    try {
      final buscarEnDB = await _dbRef.child('citas').child(idCliente).get();
      if (buscarEnDB.exists) {
        final Map<dynamic, dynamic> data = buscarEnDB.value as Map<dynamic, dynamic>;
        return data.entries.map((entry) {
          return Cita.fromJson(
            Map<String, dynamic>.from(entry.value),
            entry.key.toString(),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Cita>> obtenerTodaLaAgendaGlobal() async {
    try {
      final busquedaDB = await _dbRef.child('agenda_global').get();
      List<Cita> todasLasCitas = [];
      if (busquedaDB.exists) {
        final Map<dynamic, dynamic> dias = busquedaDB.value as Map<dynamic, dynamic>;

        dias.forEach((fechaStr, citasDelDia) {
          final Map<dynamic, dynamic> citas = citasDelDia as Map<dynamic, dynamic>;
          citas.forEach((idCita, data) {
            final resultadoDatos = Map<String, dynamic>.from(data);
            if (resultadoDatos['fecha_hora'] == null) {
              String hora = resultadoDatos['hora'] ?? "00:00";
              resultadoDatos['fecha_hora'] = "${fechaStr}T$hora:00.000";
            }
            todasLasCitas.add(Cita.fromJson(resultadoDatos, idCita.toString()));
          });
        });
      }
      return todasLasCitas;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getHorasOcupadasPorFecha(DateTime fecha) async {
    try {
      String fechaformateada = "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
      final busquedaDB = await _dbRef
          .child('agenda_global')
          .child(fechaformateada)
          .get();

      if (busquedaDB.exists) {
        final Map<dynamic, dynamic> datos =
            busquedaDB.value as Map<dynamic, dynamic>;
        List<String> horasOcupadas = [];
        datos.forEach((key, value) {
          horasOcupadas.add(value['hora']);
        });
        return horasOcupadas;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> tieneCitaMascotaEseDia(
    String idCliente,
    String idMascota,
    DateTime fecha,
  ) async {
    try {
      String fechaBusqueda = "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
      final buscarEnDB = await _dbRef.child('citas').child(idCliente).get();
      if (buscarEnDB.exists) {
        final Map<dynamic, dynamic> datos =
            buscarEnDB.value as Map<dynamic, dynamic>;

        for (var key in datos.keys) {
          var datosdelaCita = datos[key];
          if (datosdelaCita['id_mascota'].toString() == idMascota) {
            DateTime fechaCita = DateTime.parse(
              datosdelaCita['fecha_hora'].toString(),
            );
            String fechaformateada ="${fechaCita.year}-${fechaCita.month.toString().padLeft(2, '0')}-${fechaCita.day.toString().padLeft(2, '0')}";
            if (fechaformateada == fechaBusqueda) {
              return true;
            }
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> eliminarCita(Cita cita) async {
    try {
      await _dbRef
          .child('citas')
          .child(cita.idCliente)
          .child(cita.idCita)
          .remove();

      String fechaformateada = "${cita.fechaHora.year}-${cita.fechaHora.month.toString().padLeft(2, '0')}-${cita.fechaHora.day.toString().padLeft(2, '0')}";
      await _dbRef
          .child('agenda_global')
          .child(fechaformateada)
          .child(cita.idCita)
          .remove();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAgendaDelDia(DateTime fecha) async {
    try {
      String fechaFormateada = "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
      final busquedaDB = await _dbRef
          .child('agenda_global')
          .child(fechaFormateada)
          .get();

      if (busquedaDB.exists) {
        final Map<dynamic, dynamic> datosRecogidos = busquedaDB.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> citasDelDia = [];
        datosRecogidos.forEach((key, value) {
          citasDelDia.add(Map<String, dynamic>.from(value));
        });
        return citasDelDia;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  //Método reactivo para que el veterinario en su panel agenda les muestre algún cambio de FB en el apartado Agenda global.
  Stream<List<Map<String, dynamic>>> flujoAgenda(DateTime fecha) {
    final String fechaFormateada = "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";

    return _dbRef
        .child('agenda_global')
        .child(fechaFormateada)
        .onValue
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final Map<dynamic, dynamic> datos = event.snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> citasDelDia = [];
      datos.forEach((key, value) {
        citasDelDia.add(Map<String, dynamic>.from(value));
      });
      return citasDelDia;
    });
  }
}