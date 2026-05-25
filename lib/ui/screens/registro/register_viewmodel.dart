import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawter/data/models/usuarios.dart';
import 'package:pawter/data/models/enums/rol_usuario.dart';
import 'package:pawter/ui/screens/registro/register_state.dart';
import 'package:pawter/data/repositories/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  RegisterState _state = RegisterState();
  RegisterState get state => _state;

  void onNombreChange(String value) {
    if (value.isEmpty || value.length < 3) {
      _state = _state.copyWith(
        nombre: value,
        nombreError: "El nombre debe tener al menos 3 letras",
        clearNombreError: false,
      );
    } else {
      _state = _state.copyWith(nombre: value, clearNombreError: true);
    }
    notifyListeners();
  }

  void onEmailChange(String value) {
    if (value.isEmpty || !EmailValidator.validate(value)) {
      _state = _state.copyWith(
        email: value,
        emailError: "Introduce un correo válido",
        clearEmailError: false,
      );
    } else {
      _state = _state.copyWith(email: value, clearEmailError: true);
    }
    notifyListeners();
  }

  void onPasswordChange(String value) {
    if (value.length < 6) {
      _state = _state.copyWith(
        password: value,
        passwordError: "Mínimo 6 caracteres",
        clearPasswordError: false,
      );
    } else {
      _state = _state.copyWith(password: value, clearPasswordError: true);
    }

    if (_state.confirmPassword.isNotEmpty) {
      onConfirmPasswordChange(_state.confirmPassword);
    } else {
      notifyListeners();
    }
  }

  void onConfirmPasswordChange(String value) {
    if (value != _state.password) {
      _state = _state.copyWith(
        confirmPassword: value,
        confirmPasswordError: "Las contraseñas no coinciden",
        clearConfirmPasswordError: false,
      );
    } else {
      _state = _state.copyWith(
        confirmPassword: value,
        clearConfirmPasswordError: true,
      );
    }
    notifyListeners();
  }

  Future<void> onRegisterSubmit({
    required Function(Usuario) onSuccess,
    required Function(String) onError,
  }) async {
    if (_state.nombreError != null ||
        _state.emailError != null ||
        _state.passwordError != null ||
        _state.confirmPasswordError != null ||
        _state.nombre.isEmpty ||
        _state.email.isEmpty ||
        _state.password.isEmpty) {
      onError("Por favor, corrige los errores en rojo antes de continuar.");
      return;
    }

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      Usuario datosParaGuardar = Usuario(
        id: '',
        nombre: _state.nombre,
        email: _state.email,
        rol: RolUsuario.cliente,
        fechaRegistro: DateTime.now(),
        telefono: null,
        dni: null,
        direccion: null,
      );

      User? firebaseUser = await _repo.emailRegistro(
        _state.email,
        _state.password,
        datosParaGuardar,
      );

      if (firebaseUser != null) {
        Usuario usuarioFinal = datosParaGuardar.copyWith(id: firebaseUser.uid);

        await _repo.enviarEmailVerificacion();
        await _repo.deslogear();
        _state = _state.copyWith(isLoading: false);
        notifyListeners();
        onSuccess(usuarioFinal);
      } else {
        throw Exception("No se pudo obtener el usuario.");
      }
    } on FirebaseAuthException catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();

      String errorMsg = "Error al crear la cuenta";
      if (e.code == 'email-already-in-use') {
        errorMsg = "Este correo electrónico ya está registrado.";
      } else if (e.code == 'weak-password') {
        errorMsg = "La contraseña es demasiado débil.";
      } else if (e.code == 'invalid-email') {
        errorMsg = "El formato del correo no es válido.";
      }

      onError(errorMsg);
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      onError("Hubo un problema: ${e.toString()}");
    }
  }
}