import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawter/ui/screens/acceso/Agendar_Cita/franja_horas.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/data/models/citas.dart';
import 'package:pawter/data/repositories/citas_repository.dart';

class AgendarCitaViewModel extends ChangeNotifier {
  final Mascota mascota;
  final String idUsuario; 
  final CitasRepository _repo = CitasRepository();

  DateTime diaActual = DateTime.now();
  DateTime elegirDia = DateTime.now();
  List<String> horasDisponibles = [];
  String? horaSeleccionada;
  bool mascotaTieneCita = false;
  TextEditingController motivoCitaController = TextEditingController();
  bool estaCargando = false;

  AgendarCitaViewModel({required this.mascota, required this.idUsuario}) {
    _cargarHorasDelDia(elegirDia);
    motivoCitaController.addListener(() {
      notifyListeners();
    });
  }
  //Este metodo compara si el dia pulsado es distinto al seleccionado, esto se activa cuando el usuario toca un día diferente en el calendario
  void diaSelecionado(DateTime elegirDia, DateTime diaActual) {
    if (!isSameDay(this.elegirDia, elegirDia)) {
      this.elegirDia = elegirDia;
      this.diaActual = diaActual;
      horaSeleccionada = null;
      _cargarHorasDelDia(elegirDia);
    }
  }

  void seleccionarHora(String hora) {
    horaSeleccionada = hora;
    notifyListeners();
  }
  /*
    metodo privado que mira si la mascota tiene cita ese día, si ya tiene no deja agendar.
     Si está libre comprueba en FB que horas están ocupadas por otros clientes
  */
  Future<void> _cargarHorasDelDia(DateTime fecha) async {
    estaCargando = true;
    notifyListeners();

    try {
      mascotaTieneCita = await _repo.tieneCitaMascotaEseDia(
        idUsuario,
        mascota.idMascota.toString(),
        fecha,
      );

      if (mascotaTieneCita) {
        horasDisponibles = [];
      } else {
        List<String> horasOcupadas = await _repo.getHorasOcupadasPorFecha(fecha);
        List<String> todaslasFranjas = FranjaHorario.getFranjaHoraria();
        List<String> resultadoFiltrarHorario = todaslasFranjas
            .where((hora) => !horasOcupadas.contains(hora))
            .toList();

        //añado una condición de 15 minutos para que un usuario no pueda en en ultimo segundo añadir una cita.
        if (isSameDay(fecha, DateTime.now())) {
          final restriccion15min = DateTime.now().add( Duration(minutes: 15));

          horasDisponibles = resultadoFiltrarHorario.where((horaStr) {
            List<String> partes = horaStr.split(":");
            int horaFranja = int.parse(partes[0]);
            int minFranja = int.parse(partes[1]);
            DateTime nuevaFecha = DateTime(
              fecha.year,
              fecha.month,
              fecha.day,
              horaFranja,
              minFranja,
            );
            return nuevaFecha.isAfter(restriccion15min);
          }).toList();
        } else {
          horasDisponibles = resultadoFiltrarHorario;
        }
      }
    } catch (e) {
      horasDisponibles = [];
    } finally {
      estaCargando = false;
      notifyListeners();
    }
  }
  /*
    Metodo que confirma la reserva, primero verificando la hora y el motivo(controller), identifica el usuario despues en
     Firebase, crea una cita y si todo sale bien lo sube a la nube y ejecuta el onSuccess
  */
  Future<void> agendarCita({required VoidCallback onSuccess, required Function(String) onError}) async 
  {
    if (horaSeleccionada == null ||motivoCitaController.text.isEmpty || mascotaTieneCita) {
      return;
    }
    estaCargando = true;
    notifyListeners();
    try {
      final horasOcupadasAhora = await _repo.getHorasOcupadasPorFecha(elegirDia);
      if (horasOcupadasAhora.contains(horaSeleccionada)) {
        //La hora ya está cogida , desmarca y refresca el listado
        horaSeleccionada = null;
        await _cargarHorasDelDia(elegirDia);
        onError("Esa hora acaba de ser reservada por otro usuario.\nElige otra hora disponible.");
        return;
      }

      List<String> partesHora = horaSeleccionada!.split(":");
      int hora = int.parse(partesHora[0]);
      int minuto = int.parse(partesHora[1]);
      DateTime fechaHoraFinal = DateTime(elegirDia.year,elegirDia.month,elegirDia.day,hora,minuto);
      //si la cita la crea un cliente no va a saber qué veterinario lo atenderá, por lo que se deja sin asignar. Si el usuario que lo crea
      //es veterinario entonces si lo sabe y lo igualo al usuario id
      final usuario = FirebaseAuth.instance.currentUser;
      String idVeterinario = "sin_asignar"; 
      if (usuario != null && usuario.uid != idUsuario) {
        idVeterinario = usuario.uid;
      }
      final citaNueva = Cita(
        idCita: DateTime.now().millisecondsSinceEpoch.toString(),
        idVeterinario: idVeterinario,
        idCliente: idUsuario,
        idMascota: mascota.idMascota.toString(),
        fechaHora: fechaHoraFinal,
        motivo: motivoCitaController.text,
      );

      await _repo.guardarCita(citaNueva);
      onSuccess();
    } catch (_) {}
     finally {
      estaCargando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    motivoCitaController.dispose();
    super.dispose();
  }
}