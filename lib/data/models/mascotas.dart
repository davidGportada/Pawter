class Mascota {
  final int idMascota;
  final String idDueno;
  final String nombre;
  final String especie;
  final double peso;
  final String raza;
  final DateTime fechaNacimiento;
  final String? fotoUrl;
  final String? alergias;

  Mascota({
    required this.idMascota,
    required this.idDueno,
    required this.nombre,
    required this.especie,
    required this.peso,
    required this.raza,
    required this.fechaNacimiento,
    this.fotoUrl,
    this.alergias,
  });

  int get edad {
    final hoy = DateTime.now();
    int edadCalculada = hoy.year - fechaNacimiento.year;

    if (hoy.month < fechaNacimiento.month ||
        (hoy.month == fechaNacimiento.month && hoy.day < fechaNacimiento.day)) {
      edadCalculada--;
    }
    return edadCalculada;
  }

  factory Mascota.fromJson(Map<String, dynamic> json) {
    String pesoString =
        json['peso']
            ?.toString()
            .replaceAll(',', '.')
            .replaceAll(RegExp(r'[^0-9.]'), '') ??
        '0.0';

    return Mascota(
      idMascota: int.tryParse(json['id_mascota']?.toString() ?? '0') ?? 0,
      idDueno: json['id_dueno']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      especie: json['especie']?.toString() ?? '',
      peso: double.tryParse(pesoString) ?? 0.0,
      raza: json['raza']?.toString() ?? '',
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.tryParse(json['fecha_nacimiento'].toString()) ??
                DateTime.now()
          : DateTime.now(),
      fotoUrl: json['foto_url']?.toString(),
      alergias: json['alergias']?.toString(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_mascota': idMascota,
      'id_dueno': idDueno,
      'nombre': nombre,
      'especie': especie,
      'peso': peso,
      'raza': raza,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'foto_url': fotoUrl,
      'alergias': alergias,
    };
  }
}
