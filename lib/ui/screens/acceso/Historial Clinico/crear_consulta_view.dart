import 'package:flutter/material.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/ui/utils/app_colors.dart';
import 'package:pawter/widgets/texto_field.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/screens/acceso/veterinario/vet_viewmodel.dart';
import 'crearconsulta_viewmodel.dart';

class CrearConsultaView extends StatelessWidget {
  final Mascota mascota;
  const CrearConsultaView({super.key, required this.mascota});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CrearConsultaViewModel(mascota),
      child: Consumer<CrearConsultaViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: AppColors.blancoTiza,
          appBar: AppBar(
            title: Text(
              "Nueva consulta", 
              style: TextStyle(color: AppColors.darkTeal, fontWeight: FontWeight.bold)
            ), 
            iconTheme: IconThemeData(color: AppColors.darkTeal),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: vm.tipoSeleccionado,
                  decoration: InputDecoration(
                    labelText: "Tipo de atención", 
                    labelStyle: TextStyle(color: AppColors.textGrey),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    filled: true, 
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), 
                      borderSide: BorderSide(color: AppColors.black10)
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.black10)
                    ),
                  ),
                  items: ['Revision', 'Vacuna', 'Urgencia', 'Otros']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) vm.setTipoSeleccionado(val);
                  },
                ),
                SizedBox(height: 16),
                TextoCampoInicio(
                  label: "Peso actual (Kg)", 
                  hint: "0.0", 
                  icon: Icons.monitor_weight, 
                  bgColor: AppColors.white, 
                  controller: vm.pesoController, 
                  keyboardType: TextInputType.numberWithOptions(decimal: true)
                ),
                SizedBox(height: 16),
                TextoCampoInicio(
                  label: "Motivo / Título", 
                  hint: "Ej: Limpieza de oídos", 
                  icon: Icons.title, 
                  bgColor: AppColors.white, 
                  controller: vm.tituloController
                ),
                SizedBox(height: 24),
                
                TextoCampoInicio(
                  label: "Diagnóstico", 
                  hint: "Detalla la exploración física", 
                  bgColor: AppColors.white, 
                  controller: vm.diagController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                ),
                SizedBox(height: 16),
                
                TextoCampoInicio(
                  label: "Tratamiento", 
                  hint: "Medicinas, dosis, próximos pasos...", 
                  bgColor: AppColors.white, 
                  controller: vm.tratController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                ),
                
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: vm.cargando 
                      ? null 
                      : () {
                          String nombreVet = "Veterinario";
                          try {
                            final vmVet = context.read<VeterinarioViewModel>();
                            if (vmVet.usuario != null) nombreVet = "Dr. ${vmVet.usuario!.nombre}";
                          } catch (_) {}

                          vm.guardarConsulta(
                            mascota: mascota, 
                            nombreVet: nombreVet,
                            conExito: () {
                              try {
                                final vetVM = context.read<VeterinarioViewModel>();
                                vetVM.cargarDirectorioCompleto();
                              } catch (_) {}
                              Navigator.pop(context, true);
                            }
                          );
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: vm.cargando 
                      ? const SizedBox(
                          width: 24, 
                          height: 24, 
                          child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 3)
                        )
                      : const Text(
                          "Finalizar consulta", 
                          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}