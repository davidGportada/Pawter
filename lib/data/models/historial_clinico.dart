class HistorialClinico {
  final int idRegistro;
  final int idMascota;
  final String? titulo;
  final String? nombreVeterinario;
  final String? tipoRegistro;
  final double? pesoKg;
  final String? diagnostico;
  final String? tratamiento;
  final DateTime fecha;

  HistorialClinico({
    required this.idRegistro,
    required this.idMascota,
    this.titulo,
    this.nombreVeterinario,
    this.tipoRegistro,
    this.pesoKg,
    this.diagnostico,
    this.tratamiento,
    required this.fecha,
  });

  factory HistorialClinico.fromJson(Map<String, dynamic> json) {
    return HistorialClinico(
      idRegistro: json['idRegistro'],
      idMascota: json['idMascota'],
      titulo: json['titulo'],
      nombreVeterinario: json['nombreVeterinario'],
      tipoRegistro: json['tipoRegistro'],
      pesoKg: json['pesoKg'] != null ? (json['pesoKg'] as num).toDouble() : null,
      diagnostico: json['diagnostico'],
      tratamiento: json['tratamiento'],
      fecha: DateTime.parse(json['fecha']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRegistro': idRegistro,
      'idMascota': idMascota,
      'titulo': titulo,
      'nombreVeterinario': nombreVeterinario,
      'tipoRegistro': tipoRegistro,
      'pesoKg': pesoKg,
      'diagnostico': diagnostico,
      'tratamiento': tratamiento,
      'fecha': fecha.toIso8601String(),
    };
  }
}