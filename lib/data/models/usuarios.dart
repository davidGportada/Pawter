import 'package:pawter/data/models/enums/rol_usuario.dart';

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String? telefono;
  final String? dni;
  final String? direccion;
  final RolUsuario rol;
  final DateTime fechaRegistro;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    this.dni,
    this.direccion,
    required this.rol,
    required this.fechaRegistro,
  });

  Usuario copyWith({
    String? id,
    String? nombre,
    String? email,
    String? telefono,
    String? dni,
    String? direccion,
    RolUsuario? rol,
    DateTime? fechaRegistro,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      dni: dni ?? this.dni,
      direccion: direccion ?? this.direccion,
      rol: rol ?? this.rol,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id_usuario'] ?? '',
        nombre: json['nombre'] ?? '',
        email: json['email'] ?? '',
        telefono: json['telefono'],
        dni: json['dni'],
        direccion: json['direccion'],
        rol: RolUsuario.tryParse(json['rol'] ?? 'cliente') ?? RolUsuario.cliente,
        fechaRegistro: json['fecha_registro'] != null
            ? DateTime.parse(json['fecha_registro'].toString())
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id_usuario': id,
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'dni': dni,
        'direccion': direccion,
        'rol': rol.name,
        'fecha_registro': fechaRegistro.toIso8601String(),
      };
}