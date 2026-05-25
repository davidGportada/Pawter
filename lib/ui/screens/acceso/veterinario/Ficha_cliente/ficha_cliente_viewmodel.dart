import 'package:flutter/material.dart';
import 'package:pawter/data/models/usuarios.dart';
import 'package:pawter/data/repositories/auth_repository.dart';

class FichaClienteViewModel extends ChangeNotifier {
  final Usuario cliente;
  final AuthRepository _repo = AuthRepository();
  late TextEditingController dniController;
  late TextEditingController telefonoController;
  late TextEditingController direccionController;
  bool _cargando = false;
  bool get cargando => _cargando;

  FichaClienteViewModel({required this.cliente}) {
    dniController = TextEditingController(text: cliente.dni ?? "");
    telefonoController = TextEditingController(text: cliente.telefono ?? "");
    direccionController = TextEditingController(text: cliente.direccion ?? "");
    dniController.addListener(_validar);
    telefonoController.addListener(_validar);
    direccionController.addListener(_validar);
  }

  void _validar() => notifyListeners();

  bool get puedeGuardar {
    return dniController.text.trim().isNotEmpty &&
        telefonoController.text.trim().isNotEmpty &&
        direccionController.text.trim().isNotEmpty;
  }

  Future<void> guardarCambios() async {
    _cargando = true;
    notifyListeners();
    try {
      await _repo.actualizarDatosCliente(
        cliente.id,
        dniController.text.trim(),
        telefonoController.text.trim(),
        direccionController.text.trim(),
      );
    } catch (_) {
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    dniController.dispose();
    telefonoController.dispose();
    direccionController.dispose();
    super.dispose();
  }
}
