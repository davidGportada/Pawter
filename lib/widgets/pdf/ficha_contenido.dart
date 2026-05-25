import 'package:flutter/material.dart';
import 'package:pawter/data/models/historial_clinico.dart';
import 'package:pawter/data/models/mascotas.dart';

class FichaClinicaLogic {
  static String obtenerTxtAlergias(String? alergias) {
    if (alergias == null || alergias.trim().isEmpty) {
      return "Sin alergias.";
    }
    return alergias;
  }

  static String obtenerFechaInforme(DateTime fecha) {
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
  }

  static List<Map<String, String>> obtenerInfoGeneral(
      HistorialClinico registro, Mascota mascota, dynamic usuario) {
    return [
      {
        "izq_label": "Número de revisión:",
        "izq_val": "${registro.idRegistro}",
        "der_label": "Información tutor:",
        "der_val": "${usuario?.nombre ?? 'No registrado'}"
      },
      {
        "izq_label": "Paciente:",
        "izq_val": mascota.nombre,
        "der_label": "DNI / NIF:",
        "der_val": "${usuario?.dni ?? 'No registrado'}"
      },
      {
        "izq_label": "Causa de atención:",
        "izq_val": registro.tipoRegistro?.toUpperCase() ?? 'GENERAL',
        "der_label": "Teléfono:",
        "der_val": "${usuario?.telefono ?? 'No registrado'}"
      },
      {
        "izq_label": "Edad:",
        "izq_val": "${mascota.edad} años",
        "der_label": "Dirección:",
        "der_val": "${usuario?.direccion ?? 'No registrado'}"
      },
      {
        "izq_label": "Peso Actual:",
        "izq_val": "${registro.pesoKg ?? mascota.peso} kg",
        "der_label": "Email:",
        "der_val": "${usuario?.email ?? 'No registrado'}"
      },
    ];
  }
}


class FilaDoble extends StatelessWidget {
  final Widget izq;
  final Widget der;
  const FilaDoble({super.key, required this.izq, required this.der});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: izq),
          Container(width: 1, color: Colors.black),
          Expanded(child: der),
        ],
      ),
    );
  }
}

class FilaUnica extends StatelessWidget {
  final Widget contenido;
  const FilaUnica(this.contenido, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black)),
      ),
      child: contenido,
    );
  }
}

class Celda extends StatelessWidget {
  final String texto;
  final bool negrita;
  final bool fondoGris;
  final double altoMinimo;

  const Celda(
    this.texto, {
    super.key,
    this.negrita = false,
    this.fondoGris = false,
    this.altoMinimo = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: altoMinimo),
      padding: const EdgeInsets.all(8),
      color: fondoGris ? Colors.grey.shade300 : Colors.transparent,
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontWeight: negrita ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}