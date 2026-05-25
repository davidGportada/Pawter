import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pawter/ui/screens/verificar_Rol/verificar_rol_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/utils/app_colors.dart';

class VerificarRol extends StatefulWidget {
  const VerificarRol({super.key});
  @override
  State<VerificarRol> createState() => _VerificarRol();
}

class _VerificarRol extends State<VerificarRol> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _comprobarAcceso());
  }

  Future<void> _comprobarAcceso() async {
    final vmRol = context.read<VerificarRolViewModel>();
    try {
      //le pido al ViewModel la ruta inicial
      final rutaDestino = await vmRol.obtenerRutaInicial();
      
      if (mounted) {
        context.go(rutaDestino);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de la conexión")),
        );
        context.go('/login'); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}