import 'package:flutter/material.dart';
import 'package:pawter/ui/utils/app_colors.dart';
import 'package:pawter/ui/screens/acceso/mascota/creareditar_mascota.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/screens/acceso/cliente/cliente_viewmodel.dart';

class TarjetaNuevaMascota extends StatelessWidget {
  const TarjetaNuevaMascota({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ClienteViewModel>();
    return Column(
      children: [
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkTeal, size: 24),
                onPressed: () {
                  final indiceAnterior = vm.misMascotas.length - 1;
                  if (indiceAnterior >= 0) {
                    // Vuelve a la última mascota registrada
                    vm.detallesController.animateToPage(
                      indiceAnterior,
                      duration: Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    //si no tiene mascotas, vuelve al inicio
                    vm.actualizarIndice(0);
                  }
                },
              ),
              Spacer(),
            ],
          ),
        ),

        SizedBox(height: 60),
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: AppColors.black10, blurRadius: 15)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline, size: 80, color: AppColors.primaryGreen),
                SizedBox(height: 20),
                Text(
                  "¿Nueva mascota?",
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.darkTeal
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Registra un nuevo compañero",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textGrey),
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CrearMascotaView()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkTeal,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text(
                      "Registrar ahora",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}