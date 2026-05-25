import 'package:flutter/material.dart';
import 'package:pawter/data/models/citas.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/data/repositories/citas_repository.dart';

class CalendarioViewModel extends ChangeNotifier {
  final CitasRepository _repo = CitasRepository();
  DateTime _diaActual = DateTime.now();
  DateTime _diaElegido = DateTime.now();
  DateTime get diaActual => _diaActual;
  DateTime get diaElegido => _diaElegido;
  Map<DateTime, List<Cita>> _citasReales = {};
  Map<DateTime, List<Cita>> get citasReales => _citasReales;
  bool _esVeterinario = false;
  bool get esVeterinario => _esVeterinario;

  CalendarioViewModel({DateTime? fechaInicial, bool esVeterinario = false}) {
    _esVeterinario = esVeterinario;
    if (fechaInicial != null) {
      _diaActual = fechaInicial;
      _diaElegido = fechaInicial;
    }
  }

  /*
  método que comprueba si eres veterinario descarga toda la agenda de FB. Si eres cliente
  usa otro metodo del repositorio para clientes.
  */
  Future<void> cargarDatos(String? idCliente) async {
    List<Cita> usuariosBD = [];
    
    if (_esVeterinario) {
      usuariosBD = await _repo.obtenerTodaLaAgendaGlobal(); 
    } else if (idCliente != null) {
      usuariosBD = await _repo.getCitasCliente(idCliente);
    }
    _citasReales = _agruparCitasPorDia(usuariosBD);
    notifyListeners();
  }
  //metodo para borrar una cita
  Future<void> eliminarCita(Cita cita) async {
    try {
      await _repo.eliminarCita(cita);
      DateTime horaformateada = DateTime.utc(cita.fechaHora.year, cita.fechaHora.month, cita.fechaHora.day);
      
      if (_citasReales.containsKey(horaformateada)) {
        _citasReales[horaformateada]!.removeWhere((c) => c.idCita == cita.idCita);
        if (_citasReales[horaformateada]!.isEmpty) {
          _citasReales.remove(horaformateada);
        }
        notifyListeners();
      }
    } catch (_) {}
  }
  //metodo para organizar las citas
  Map<DateTime, List<Cita>> _agruparCitasPorDia(List<Cita> citas) {
    Map<DateTime, List<Cita>> datos = {};
    for (var cita in citas) {
      DateTime horaformateada = DateTime.utc(cita.fechaHora.year, cita.fechaHora.month, cita.fechaHora.day);
      if (datos[horaformateada] == null) {
        datos[horaformateada] = [];
      }
      datos[horaformateada]!.add(cita);
    }
    return datos;
  }
  //metodo para actualizar en el calendario el dia/mes en la interfaz
  void diaSeleccionado(DateTime diaElegido, DateTime diaActual) {
    _diaElegido = diaElegido;
    _diaActual = diaActual;
    notifyListeners();
  }
  //método que mira si tiene cita a una hora determinada
  bool tieneCita(DateTime day) {
    DateTime horaUTC = DateTime.utc(day.year, day.month, day.day);
    return _citasReales.containsKey(horaUTC);
  }

  /*
  Método que busca la cita del día pedido por parámetro, mira el id de mascota
  y luego devuelve la url de la foto de la pet
  */
  String? obtenerFotoMascotaParaDia(DateTime day, List<Mascota> directorioMascotas) {
    DateTime horaUTC = DateTime.utc(day.year, day.month, day.day);
    
    if (_citasReales.containsKey(horaUTC) && _citasReales[horaUTC]!.isNotEmpty) {
      Cita primeraCita = _citasReales[horaUTC]!.first;
      try {
        final mascota = directorioMascotas.firstWhere(
          (m) => m.idMascota.toString() == primeraCita.idMascota.toString()
        );
        return mascota.fotoUrl;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}