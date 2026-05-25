import 'package:pawter/data/models/citas.dart';

class FranjaHorario {
  static const List<String> _horasManana = [
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30"
  ];
  static const List<String> _horasTarde = [
    "16:00", "16:30", "17:00", "17:30"
  ];

  static List<String> getFranjaHoraria() {
    return [..._horasManana, ..._horasTarde];
  }

  static List<String> getHorasDisponibles(List<Cita> citasDelDia) {
    List<String> todasLasHoras = getFranjaHoraria();
    
    //Cualquier cita que llegue aquí se considera que ocupa el espacio
    List<String> horasOcupadas = citasDelDia.map((cita) {
          String hh = cita.fechaHora.hour.toString().padLeft(2, '0');
          String mm = cita.fechaHora.minute.toString().padLeft(2, '0');
          return "$hh:$mm";
        }).toList();

    return todasLasHoras.where((h) => !horasOcupadas.contains(h)).toList();
  }
}