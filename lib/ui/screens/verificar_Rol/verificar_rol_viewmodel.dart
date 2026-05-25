import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawter/data/models/enums/rol_usuario.dart';
import 'package:pawter/data/repositories/auth_repository.dart';
import 'package:pawter/ui/home/navhost.dart';

class VerificarRolViewModel extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();

  Future<String> obtenerRutaInicial() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return AppRoutes.login;

    try {
      final usuarioDB = await _authRepo
          .getDatosDelUsuario(user.uid)
          .timeout(const Duration(seconds: 8));

      if (usuarioDB != null) {
        return (usuarioDB.rol == RolUsuario.veterinario)
            ? AppRoutes.vet
            : AppRoutes.cliente;
      } else {
        await _authRepo.deslogear();
        return AppRoutes.login;
      }
    } catch (e) {

      return AppRoutes.login;
    }
  }
}