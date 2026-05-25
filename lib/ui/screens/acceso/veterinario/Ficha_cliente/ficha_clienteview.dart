import 'package:flutter/material.dart';
import 'package:pawter/ui/screens/acceso/veterinario/Ficha_cliente/ficha_cliente_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/utils/app_colors.dart';
import 'package:pawter/data/models/usuarios.dart';

class FichaClienteView extends StatelessWidget {
  final Usuario cliente;

  const FichaClienteView({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FichaClienteViewModel(cliente: cliente),
      child: Consumer<FichaClienteViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.bgGradientStart, AppColors.bgGradientEnd],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Text(
                          "Ficha del Cliente",
                          style: TextStyle(
                            color: AppColors.darkTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _campoLectura(
                            label: "Nombre Completo",
                            valor: cliente.nombre,
                            icono: Icons.person,
                          ),
                          SizedBox(height: 16),
                          _campoLectura(
                            label: "Correo Electrónico",
                            valor: cliente.email,
                            icono: Icons.alternate_email,
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(color: AppColors.black10),
                          ),

                          _inputFicha(
                            controller: vm.dniController,
                            label: "DNI / NIF",
                            hint: "Introduce el documento",
                            icon: Icons.badge_outlined,
                          ),
                          SizedBox(height: 16),
                          _inputFicha(
                            controller: vm.telefonoController,
                            label: "Móvil",
                            hint: "Ej: 000 000 000",
                            icon: Icons.phone_android,
                            type: TextInputType.phone,
                          ),
                          SizedBox(height: 16),
                          _inputFicha(
                            controller: vm.direccionController,
                            label: "Dirección de casa",
                            hint: "Calle/Avd, número, piso...",
                            icon: Icons.home_outlined,
                          ),

                          SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: vm.puedeGuardar && !vm.cargando
                                  ? () async {
                                      try {
                                        await vm.guardarCambios();
                                        if (context.mounted) Navigator.pop(context);
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("Error: $e"),
                                              backgroundColor: AppColors.lightRed,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                disabledBackgroundColor: AppColors.lightGrey,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: vm.cargando
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          color: AppColors.white, strokeWidth: 3),
                                    )
                                  : Text(
                                      "Guardar cambios",
                                      style: TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),

                         SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoLectura({
    required String label,
    required String valor,
    required IconData icono,
  }) {
    return Container(
      padding:  EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.black05),
      ),
      child: Row(
        children: [
          Icon(icono, color: AppColors.textGrey),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
              Text(valor,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputFicha({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textGrey),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.black10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.black10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
    );
  }
}