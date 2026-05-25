class Cita {
  final String idCita;
  final String idVeterinario;
  final String idCliente;
  final String idMascota;
  final DateTime fechaHora;
  final String motivo;

  Cita({
    required this.idCita,
    required this.idVeterinario,
    required this.idCliente,
    required this.idMascota,
    required this.fechaHora,
    required this.motivo,
  });

  factory Cita.fromJson(Map<String, dynamic> json, String id) {
    return Cita(
      idCita: id,
      idVeterinario: json['id_veterinario'] ?? "",
      idCliente: json['id_cliente'] ?? "",
      idMascota: json['id_mascota'] ?? "",
      fechaHora: json['fecha_hora'] != null
          ? DateTime.parse(json['fecha_hora'].toString())
          : DateTime.now(),
      motivo: json['motivo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_cita': idCita,
      'id_veterinario': idVeterinario,
      'id_cliente': idCliente,
      'id_mascota': idMascota,
      'fecha_hora': fechaHora.toIso8601String(),
      'motivo': motivo,
    };
  }
}
