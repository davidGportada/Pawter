import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawter/data/models/usuarios.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/data/models/enums/rol_usuario.dart';
import 'package:pawter/data/repositories/auth_repository.dart';
import 'package:pawter/data/repositories/citas_repository.dart';
import 'package:pawter/data/repositories/mascota_repository.dart';

class PacienteItem {
  final Mascota mascota;
  final Usuario dueno;
  PacienteItem({required this.mascota, required this.dueno});
}

class VeterinarioViewModel extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  final CitasRepository _citasRepo = CitasRepository();
  final MascotaRepository _mascotaRepo = MascotaRepository();
  StreamSubscription<void>? _mascotasSub;
  StreamSubscription<List<Usuario>>? _usuariosSub;
  StreamSubscription<List<Map<String, dynamic>>>? _agendaSub;

  int _indiceSeleccionado = 0;
  int get indiceSeleccionado => _indiceSeleccionado;
  bool _mostrarHoy = true;
  bool get mostrarHoy => _mostrarHoy;
  String? _nombreVet;
  String get nombreVet => _nombreVet ?? "Veterinario";
  Usuario? _usuario;
  Usuario? get usuario => _usuario;
  bool cargando = false;
  Map<String, dynamic> agendaMap = {};
  bool _viendoMascotas = true;
  bool get viendoMascotas => _viendoMascotas;
  final List<PacienteItem> _todosLosPacientes = [];
  List<PacienteItem> _pacientesFiltrados = [];
  List<PacienteItem> get pacientesFiltrados => _pacientesFiltrados;
  List<Usuario> _todosLosClientes = [];
  List<Usuario> _clientesFiltrados = [];
  List<Usuario> get clientesFiltrados => _clientesFiltrados;
  String _busquedaNombre = "";
  String _busquedaEmail = "";

  VeterinarioViewModel() {
    _inicializar();
  }

  Future<void> _inicializar() async {
    cargando = true;
    notifyListeners();
    try {
      await Future.wait([
        obtenerNombreVeterinario(),
        cargarDirectorioCompleto(),
        cargarTodosLosClientes(),
      ]).timeout(const Duration(seconds: 10));
    } catch (_) {
    } finally {
      cargando = false;
      notifyListeners();
    }

    _suscribirAgenda();
    _mascotasSub?.cancel();
    _mascotasSub = _mascotaRepo.mascotaCambios().listen((_) {
      cargarDirectorioCompleto();
    });

    // flujo de usuarios que actualiza clientes y directorio cuando alguien se registra o cambia sus datos
    _usuariosSub?.cancel();
    _usuariosSub =
        _authRepo.getTodosLosUsuariosStream().listen((todosLosUsuarios) {
      _todosLosClientes = todosLosUsuarios
          .where((u) => u.rol == RolUsuario.cliente)
          .toList();
      _clientesFiltrados = List.from(_todosLosClientes);
      aplicarFiltros();
      notifyListeners();
      cargarDirectorioCompleto();
    });
  }


  void _suscribirAgenda() {
    _agendaSub?.cancel();

    final DateTime fechaConsulta = _mostrarHoy
        ? DateTime.now()
        : DateTime.now().add(const Duration(days: 1));

    _agendaSub =
        _citasRepo.flujoAgenda(fechaConsulta).listen((citas) async {
      final Map<String, dynamic> nuevoMapa = {};

      for (var cita in citas) {
        final String hora = cita['hora'] ?? "";
        final String idCliente = cita['id_cliente'] ?? "";
        final String idMascotaCita = cita['id_mascota'].toString().trim();

        if (idCliente.isNotEmpty && idMascotaCita.isNotEmpty) {
          final dataMascota =
              await _mascotaRepo.obtenerDatosMascota(idCliente, idMascotaCita);
          if (dataMascota != null) {
            nuevoMapa[hora] = {
              'nombre': dataMascota['nombre']?.toString() ?? "Paciente",
              'foto': dataMascota['url_foto']?.toString() ??
                  dataMascota['foto_url']?.toString() ??
                  "",
              'motivo': cita['motivo'] ?? "Consulta",
              'idMascota': idMascotaCita,
            };
          }
        }
      }

      agendaMap = nuevoMapa;
      notifyListeners();
    });
  }

  void actualizarIndice(int nuevoIndice) {
    _indiceSeleccionado = nuevoIndice;
    notifyListeners();
  }

  void cambiarDia(bool verHoy) {
    _mostrarHoy = verHoy;
    agendaMap = {};
    notifyListeners();
    _suscribirAgenda();
  }

  void cambiarVistaPacientes(bool mascotas) {
    _viendoMascotas = mascotas;
    aplicarFiltros();
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    _mascotasSub?.cancel();
    _usuariosSub?.cancel();
    _agendaSub?.cancel();
    await _authRepo.deslogear();
  }

  Future<void> obtenerNombreVeterinario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final usuarioReal = await _authRepo.getDatosDelUsuario(user.uid);
      if (usuarioReal != null) {
        _usuario = usuarioReal;
        _nombreVet = usuarioReal.nombre;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> cargarDirectorioCompleto() async {
    try {
      final datosCruzados = await _mascotaRepo.obtenerPacientesConDueno();
      _todosLosPacientes.clear();
      for (var item in datosCruzados) {
        _todosLosPacientes.add(PacienteItem(
            mascota: item['mascota'] as Mascota,
            dueno: item['dueno'] as Usuario));
      }
      _pacientesFiltrados = List.from(_todosLosPacientes);
      aplicarFiltros();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> cargarTodosLosClientes() async {
    try {
      final usuarios = await _authRepo.getTodosLosUsuarios();
      _todosLosClientes =
          usuarios.where((u) => u.rol == RolUsuario.cliente).toList();
      _clientesFiltrados = List.from(_todosLosClientes);
    } catch (_) {}
    notifyListeners();
  }

  void aplicarFiltros({String? nombre, String? email}) {
    if (nombre != null) _busquedaNombre = nombre.toLowerCase();
    if (email != null) _busquedaEmail = email.toLowerCase();

    if (_viendoMascotas) {
      _pacientesFiltrados = _todosLosPacientes.where((item) {
        final coincideNombre =
            item.mascota.nombre.toLowerCase().contains(_busquedaNombre);
        final coincideEmail =
            item.dueno.email.toLowerCase().contains(_busquedaEmail);
        return coincideNombre && coincideEmail;
      }).toList();
    } else {
      _clientesFiltrados = _todosLosClientes.where((u) {
        final coincideNombre =
            u.nombre.toLowerCase().contains(_busquedaNombre);
        final coincideEmail = u.email.toLowerCase().contains(_busquedaEmail);
        return coincideNombre && coincideEmail;
      }).toList();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _mascotasSub?.cancel();
    _usuariosSub?.cancel();
    _agendaSub?.cancel();
    super.dispose();
  }
}