import 'package:flutter/material.dart';
import 'package:pawter/data/models/historial_clinico.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/data/models/citas.dart';
import 'package:pawter/data/repositories/historial_repository.dart';
import 'package:pawter/data/repositories/mascota_repository.dart';
import 'package:pawter/data/repositories/citas_repository.dart';

class CrearConsultaViewModel extends ChangeNotifier {
  final HistorialRepository _repo = HistorialRepository();
  final MascotaRepository _mascotaRepo = MascotaRepository();
  final CitasRepository _citasRepo = CitasRepository();

  final TextEditingController tituloController = TextEditingController();
  final TextEditingController diagController = TextEditingController();
  final TextEditingController tratController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();
  String tipoSeleccionado = 'Revision';
  bool cargando = false;

  //es el unico campo que debe estar relleno de base con la info de la mascota, el resto vacio y a completar
  CrearConsultaViewModel(Mascota mascota) {
    pesoController.text = mascota.peso.toString();
  }

  void setTipoSeleccionado(String tipo) {
    tipoSeleccionado = tipo;
    notifyListeners();
  }



  Future<void> guardarConsulta({
    required Mascota mascota, 
    required String nombreVet,
    required VoidCallback conExito,
  }) async {
    if (diagController.text.trim().isEmpty || tituloController.text.trim().isEmpty) {
      return; 
    }
    cargando = true;
    notifyListeners();
    try {
      double nuevoPeso = double.tryParse(pesoController.text.replaceAll(',', '.')) ?? mascota.peso;

      final nuevoRegistro = HistorialClinico(
        idRegistro: DateTime.now().millisecondsSinceEpoch,
        idMascota: mascota.idMascota,
        titulo: tituloController.text.trim(),
        nombreVeterinario: nombreVet,
        tipoRegistro: tipoSeleccionado,
        pesoKg: nuevoPeso,
        diagnostico: diagController.text.trim(),
        tratamiento: tratController.text.trim(),
        fecha: DateTime.now(),
      );

      await _repo.guardarRegistro(nuevoRegistro);

      //y la variable que tenía original de la mascota es sustituida por la nueva si esta es distinta de la anterior
      if (nuevoPeso != mascota.peso) {
        final mascotaActualizada = Mascota(
          idMascota: mascota.idMascota,
          idDueno: mascota.idDueno,
          nombre: mascota.nombre,
          especie: mascota.especie,
          peso: nuevoPeso,
          raza: mascota.raza,
          fechaNacimiento: mascota.fechaNacimiento,
          fotoUrl: mascota.fotoUrl,
          alergias: mascota.alergias,
        );
        await _mascotaRepo.guardarMascota(mascotaActualizada, mascota.idDueno);
      }
      //elimino la cita
      try {
        List<Cita> citasCliente = await _citasRepo.getCitasCliente(mascota.idDueno);
        final hoy = DateTime.now();
        final citaAHoy = citasCliente.firstWhere((c) => 
          c.idMascota == mascota.idMascota.toString() &&
          c.fechaHora.year == hoy.year &&
          c.fechaHora.month == hoy.month &&
          c.fechaHora.day == hoy.day
        );
        await _citasRepo.eliminarCita(citaAHoy);
      } catch (_) {}
      conExito();

    } catch (_) {} finally {
      cargando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    tituloController.dispose();
    diagController.dispose();
    tratController.dispose();
    pesoController.dispose();
    super.dispose();
  }
}