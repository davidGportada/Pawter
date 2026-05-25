import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:pawter/data/repositories/auth_repository.dart';

class RecuperarPasswordViewModel extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  
  String _email = '';
  String? _emailError;
  bool _isLoading = false;

  String get email => _email;
  String? get emailError => _emailError;
  bool get isLoading => _isLoading;

  void onEmailChange(String newEmail) {
    _email = newEmail;
    _emailError = null; 
    notifyListeners();
  }

  Future<void> onSubmit({
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    //Validaciones por la librería de EmailValidator
    if (_email.isEmpty || !EmailValidator.validate(_email)) {
      _emailError = "Introduce un correo válido";
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _repo.envioResetearPassword(_email);
      _isLoading = false;
      notifyListeners();
      onSuccess();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError("No se ha enviado el correo. Revisa si el email es correcto.");
    }
  }
}