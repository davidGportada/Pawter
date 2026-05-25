import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/data/models/usuarios.dart';
import 'package:pawter/data/models/citas.dart';
import 'package:pawter/data/models/enums/rol_usuario.dart';
import 'package:pawter/data/repositories/auth_repository.dart';
import 'package:pawter/data/repositories/mascota_repository.dart';
import 'package:pawter/data/repositories/citas_repository.dart';

class ClienteViewModel extends ChangeNotifier {
  final MascotaRepository _repoMascota = MascotaRepository();
  final CitasRepository _repoCitas = CitasRepository();
  final AuthRepository _repoUsuario = AuthRepository();
  StreamSubscription<Usuario?>? _usuarioSub;

  ClienteViewModel() {
    _comprobarSesionActiva();
  }

  int _indiceSeleccionado = 0;
  int get indiceActual => _indiceSeleccionado;
  Usuario? _usuario;
  Usuario? get usuario => _usuario;

  bool get tienePerfilCompleto {
    if (_usuario == null) return false;
    return (_usuario!.dni?.trim().isNotEmpty ?? false) &&
        (_usuario!.telefono?.trim().isNotEmpty ?? false) &&
        (_usuario!.direccion?.trim().isNotEmpty ?? false);
  }

  Mascota? _mascotaSeleccionada;
  Mascota? get mascotaSeleccionada => _mascotaSeleccionada;
  List<Mascota> _misMascotas = [];
  List<Mascota> get misMascotas => _misMascotas;
  Cita? _proximaCita;
  Cita? get proximaCita => _proximaCita;
  bool _estaCargando = false;
  bool get estaCargando => _estaCargando;
  final PageController detallesController = PageController();
  DateTime? _fechaDestinoCalendario;
  DateTime? get fechaDestinoCalendario => _fechaDestinoCalendario;

  Future<void> _comprobarSesionActiva() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;
    _estaCargando = true;
    notifyListeners();
    try {
      final usuarioInicial = await _repoUsuario
          .getDatosDelUsuario(firebaseUser.uid)
          .timeout(const Duration(seconds: 8));

      _usuario = usuarioInicial ??
          Usuario(
            id: firebaseUser.uid,
            nombre: firebaseUser.displayName ?? "Usuario",
            email: firebaseUser.email ?? "",
            rol: RolUsuario.cliente,
            fechaRegistro:
                firebaseUser.metadata.creationTime ?? DateTime.now(),
          );

      await cargarMascotas();
    } catch (_) {
      _estaCargando = false;
      notifyListeners();
    }
    _usuarioSub?.cancel();
    _usuarioSub = _repoUsuario
        .flujoGetDatosUsu(firebaseUser.uid)
        .listen((usuarioActualizado) {
      if (usuarioActualizado != null) {
        _usuario = usuarioActualizado;
        notifyListeners();
      }
    });
  }

  void establecerUsuario(Usuario usuario) {
    _usuario = usuario;
    cargarMascotas();
    notifyListeners();
  }

  Future<void> cargarMascotas() async {
    if (_usuario?.id == null) return;

    _estaCargando = true;
    notifyListeners();

    try {
      _misMascotas = await _repoMascota
          .obtenerMascotasPorDueno(_usuario!.id)
          .timeout(const Duration(seconds: 10));
      await cargarProximaCita();
    } catch (_) {
      _misMascotas = [];
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }

  Future<void> cerrarSesion() async {
    try {
      _usuarioSub?.cancel();
      _usuarioSub = null;
      await _repoUsuario.deslogear();
      _usuario = null;
      _misMascotas = [];
      _proximaCita = null;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> cargarProximaCita() async {
    if (_usuario?.id == null) return;
    try {
      final citas = await _repoCitas
          .getCitasCliente(_usuario!.id.toString())
          .timeout(const Duration(seconds: 8));
      final ahora = DateTime.now();
      final citasFuturas =
          citas.where((c) => c.fechaHora.isAfter(ahora)).toList();

      if (citasFuturas.isNotEmpty) {
        citasFuturas.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
        _proximaCita = citasFuturas.first;
      } else {
        _proximaCita = null;
      }
    } catch (e) {
      _proximaCita = null;
    }
    notifyListeners();
  }

  Future<void> actualizarFotoMascota(Mascota mascota) async {
    if (_usuario == null) return;
    final ImagePicker imagen = ImagePicker();
    final XFile? imagenSeleccionada =
        await imagen.pickImage(source: ImageSource.gallery);

    if (imagenSeleccionada != null) {
      _estaCargando = true;
      notifyListeners();
      try {
        Uint8List imagenBytes = await imagenSeleccionada.readAsBytes();
        final guardarImagen = FirebaseStorage.instance
            .ref()
            .child('mascotas')
            .child(_usuario!.id)
            .child('${mascota.idMascota}.jpg');

        await guardarImagen.putData(imagenBytes);
        String url = await guardarImagen.getDownloadURL();
        await _repoMascota.actualizarFotoMascotaBD(
            _usuario!.id, mascota.idMascota, url);
        await cargarMascotas();
      } finally {
        _estaCargando = false;
        notifyListeners();
      }
    }
  }

  void actualizarIndice(int nuevoIndice) {
    if (nuevoIndice == 2) _fechaDestinoCalendario = null;
    _indiceSeleccionado = nuevoIndice;
    notifyListeners();
  }

  void seleccionarMascota(Mascota mascota) {
    _mascotaSeleccionada = mascota;
    int indice = _misMascotas.indexOf(mascota);
    actualizarIndice(1);
    if (indice != -1) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (detallesController.hasClients) {
          detallesController.animateToPage(
            indice,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
    notifyListeners();
  }

  void irACalendarioEnFecha(DateTime fecha) {
    _fechaDestinoCalendario = fecha;
    _indiceSeleccionado = 2;
    notifyListeners();
  }

  String formatearFechaCita(DateTime fecha) {
    final hoy = DateTime.now();
    if (DateUtils.isSameDay(fecha, hoy)) return "Hoy";
    if (DateUtils.isSameDay(fecha, hoy.add(const Duration(days: 1)))) {
      return "Mañana";
    }
    final meses = [
      "enero", "febrero", "marzo", "abril", "mayo", "junio",
      "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
    ];
    return "${fecha.day} de ${meses[fecha.month - 1]}";
  }

  String formatearHora(DateTime fecha) {
    String franja = fecha.hour >= 12 ? "PM" : "AM";
    int hora12 = fecha.hour % 12 == 0 ? 12 : fecha.hour % 12;
    return "${hora12.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')} $franja";
  }

  @override
  void dispose() {
    _usuarioSub?.cancel();
    detallesController.dispose();
    super.dispose();
  }
}