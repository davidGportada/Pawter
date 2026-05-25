import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawter/data/models/usuarios.dart';
import 'package:pawter/data/repositories/auth_repository.dart';
import 'package:pawter/ui/screens/login/login_state.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repoUsuario = AuthRepository();
  LoginState _state = LoginState();
  LoginState get state => _state;

  void onEmailChange(String newEmail) {
    _state = _state.copyWith(email: newEmail, clearEmailError: true);
    notifyListeners();
  }

  void onPasswordChange(String newPassword) {
    _state = _state.copyWith(password: newPassword, clearPasswordError: true);
    notifyListeners();
  }

  Future<void> onLoginSubmit({
    required Function(Usuario) onSuccess, 
    required Function(String) onError
  }) async {
    _state = _state.copyWith(clearEmailError: true, clearPasswordError: true);
    
    if (_state.email.isEmpty || !EmailValidator.validate(_state.email)) {
      _state = _state.copyWith(emailError: "Correo no válido");
      notifyListeners();
      return;
    }
    if (_state.password.isEmpty) {
      _state = _state.copyWith(passwordError: "Introduce la contraseña");
      notifyListeners();
      return;
    }

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      User? usuarioDB = await _repoUsuario.logearConEmail(_state.email, _state.password);
      if (usuarioDB != null) {
        
        //no le permito acceder si no verifica el correo
        if (!usuarioDB.emailVerified) {
          await _repoUsuario.deslogear();
          _state = _state.copyWith(isLoading: false);
          notifyListeners();
          
          onError("Debes verificar tu correo antes de entrar. Revisa tu email.");
          return; 
        }

        Usuario? usuarioCompleto = await _repoUsuario.getDatosDelUsuario(usuarioDB.uid);

        if (usuarioCompleto != null) {
          _state = _state.copyWith(isLoading: false);
          notifyListeners();
          onSuccess(usuarioCompleto);
        } else {
          throw Exception("No se encontraron datos del usuario");
        }
      }
    } on FirebaseAuthException catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      
      //manejo de errores de acceso
      String msg = "Credenciales incorrectas";
      if (e.code == 'user-not-found') msg = "El usuario no existe";
      if (e.code == 'wrong-password') msg = "Contraseña incorrecta";
      onError(msg);
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      onError("Error inesperado: ${e.toString()}");
    }
  }
}