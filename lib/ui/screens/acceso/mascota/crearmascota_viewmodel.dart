import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/data/repositories/mascota_repository.dart';

class CrearMascotaViewModel extends ChangeNotifier {
  final MascotaRepository _repo = MascotaRepository();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController especieController = TextEditingController();
  final TextEditingController razaController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alergiasController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  Mascota? mascotaExistente;
  String? urlImagenActual;
  DateTime? _fechaNacimiento;
  Uint8List? imagenEnBytes;
  bool isLoading = false;
  String? nombreError;
  String? especieError;
  String? razaError;
  String? pesoError;
  String? fechaError;

  void cargarDatos(Mascota mascota) {
    mascotaExistente = mascota;
    urlImagenActual = mascota.fotoUrl;
    nombreController.text = mascota.nombre;
    especieController.text = mascota.especie;
    razaController.text = mascota.raza;
    pesoController.text = mascota.peso.toString();
    alergiasController.text = mascota.alergias ?? "";
    _fechaNacimiento = mascota.fechaNacimiento;
    fechaController.text = "${mascota.fechaNacimiento.day.toString().padLeft(2, '0')}/${mascota.fechaNacimiento.month.toString().padLeft(2, '0')}/${mascota.fechaNacimiento.year}";
    notifyListeners();
  }

  Future<void> seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      imagenEnBytes = await imagen.readAsBytes();
      notifyListeners();
    }
  }

  void formatearFecha(String value) {
    String cadReducida = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cadReducida.length > 8) cadReducida = cadReducida.substring(0, 8);

    String cadFormateada = '';
    for (int i = 0; i < cadReducida.length; i++) {
      cadFormateada += cadReducida[i];
      if ((i == 1 || i == 3) && i != cadReducida.length - 1) {
        cadFormateada += '/';
      }
    }
    if (fechaController.text != cadFormateada) {
      fechaController.value = TextEditingValue(
        text: cadFormateada,
        selection: TextSelection.collapsed(offset: cadFormateada.length),
      );
    }
    
    if (fechaError != null) {
      fechaError = null;
      notifyListeners();
    }
  }

  bool _validarCampos() {
    bool valido = true;

    if (nombreController.text.trim().isEmpty) { nombreError = "Obligatorio"; valido = false; } else { nombreError = null; }
    if (especieController.text.trim().isEmpty) { especieError = "Obligatorio"; valido = false; } else { especieError = null; }
    if (razaController.text.trim().isEmpty) { razaError = "Obligatorio"; valido = false; } else { razaError = null; }

    String pesoTexto = pesoController.text.replaceAll(',', '.');
    if (pesoTexto.trim().isEmpty) {
      pesoError = "Obligatorio";
      valido = false;
    } else if (double.tryParse(pesoTexto) == null) {
      pesoError = "Inválido";
      valido = false;
    } else {
      pesoError = null;
    }

    String fechaTexto = fechaController.text.trim();
    if (fechaTexto.isEmpty) {
      fechaError = "Obligatorio";
      valido = false;
    } else if (fechaTexto.length != 10) {
      fechaError = "Formato DD/MM/AAAA";
      valido = false;
    } else {
      try {
        List<String> partes = fechaTexto.split('/');
        int dia = int.parse(partes[0]);
        int mes = int.parse(partes[1]);
        int anio = int.parse(partes[2]);
        DateTime fechaParseada = DateTime(anio, mes, dia);
        //Cpndición de que el usuario no quiera poner al animal con 60+ años o que nazca antes de la fecha actual
        if (fechaParseada.year != anio || fechaParseada.month != mes || fechaParseada.day != dia) {
          fechaError = "Fecha irreal";
          valido = false;
        } else if (fechaParseada.isAfter(DateTime.now())) {
          fechaError = "Pon una fecha actual o antigua";
          valido = false;
        } else if (anio < 1990) {
          fechaError = "Pon una fecha actual o por encima de los 90";
          valido = false;
        } else {
          _fechaNacimiento = fechaParseada;
          fechaError = null;
        }
      } catch (e) {
        fechaError = "Formato inválido";
        valido = false;
      }
    }

    notifyListeners();
    return valido;
  }

  Future<void> guardar(String userId, {required VoidCallback exito}) async {
    if (!_validarCampos()) return;
    isLoading = true;
    notifyListeners();

    try {
      String? urlImagen = urlImagenActual;
      if (imagenEnBytes != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('mascotas')
            .child(userId)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await storageRef.putData(imagenEnBytes!);
        urlImagen = await storageRef.getDownloadURL();
      }

      final nuevaMascota = Mascota(
        idMascota: mascotaExistente?.idMascota ?? DateTime.now().millisecondsSinceEpoch,
        idDueno: mascotaExistente?.idDueno ?? userId,
        nombre: nombreController.text.trim(),
        especie: especieController.text.trim(),
        peso: double.parse(pesoController.text.replaceAll(',', '.')),
        raza: razaController.text.trim(),
        fechaNacimiento: _fechaNacimiento!,
        alergias: alergiasController.text.trim(),
        fotoUrl: urlImagen,
      );

      await _repo.guardarMascota(nuevaMascota, nuevaMascota.idDueno);
      exito();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    especieController.dispose();
    razaController.dispose();
    pesoController.dispose();
    alergiasController.dispose();
    fechaController.dispose();
    super.dispose();
  }
}