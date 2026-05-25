import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:pawter/ui/screens/verificar_Rol/verificar_rol.dart';
import 'package:pawter/ui/screens/verificar_Rol/verificar_rol_viewmodel.dart';
import 'package:pawter/ui/screens/acceso/cliente/cliente_home.dart';
import 'package:pawter/ui/screens/acceso/veterinario/veterinario_home.dart';
import 'package:pawter/ui/screens/login/login_viewmodel.dart';
import 'package:pawter/ui/screens/registro/register_view.dart';
import 'package:pawter/ui/screens/registro/register_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/screens/login/login_view.dart';

class AppRoutes {
  static const String login = "/login";
  static const String registro = "/register";
  static const String verificarRol = "/verificar-rol";
  static const String cliente = "/client-dashboard";
  static const String vet = "/vet-dashboard";
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  redirect: (context, state) {
    final User? usuarioDB = FirebaseAuth.instance.currentUser;
    final bool estaEnLogin = state.matchedLocation == AppRoutes.login;
    final bool estaEnRegistro = state.matchedLocation == AppRoutes.registro;

    if (usuarioDB == null && !estaEnLogin && !estaEnRegistro) {
      return AppRoutes.login;
    }

    if (usuarioDB != null && (estaEnLogin || estaEnRegistro)) {
      return AppRoutes.verificarRol;
    }
    return null;
  },

  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => LoginViewModel(),
        child: LoginScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.registro,
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => RegisterViewModel(),
        child: RegisterScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.verificarRol,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => VerificarRolViewModel(),
        child: const VerificarRol(),
      ),
    ),
    GoRoute(
      path: AppRoutes.cliente,
      builder: (context, state) => const ClienteHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.vet,
      builder: (context, state) => const VeterinarioHomeScreen(),
    ),
  ],
);