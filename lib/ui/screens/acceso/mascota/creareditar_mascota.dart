import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/utils/app_colors.dart';
import 'package:pawter/ui/screens/acceso/cliente/cliente_viewmodel.dart';
import 'package:pawter/ui/screens/acceso/mascota/crearmascota_viewmodel.dart';
import 'package:pawter/widgets/texto_field.dart';
import 'package:pawter/data/models/mascotas.dart'; 

class CrearMascotaView extends StatelessWidget {
  final Mascota? mascotaAEditar; 
  const CrearMascotaView({super.key, this.mascotaAEditar});

  @override
  Widget build(BuildContext context) {
    ClienteViewModel? vmCliente;
    try { vmCliente = context.read<ClienteViewModel>(); } catch (_) {}
    
    return ChangeNotifierProvider(
      create: (_) {
        final vmMascota = CrearMascotaViewModel();
        if (mascotaAEditar != null) vmMascota.cargarDatos(mascotaAEditar!); 
        return vmMascota;
      },
      child: Consumer<CrearMascotaViewModel>(
        builder: (context, vm, _) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.bgGradientStart, AppColors.bgGradientEnd],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: AppColors.darkTeal),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                mascotaAEditar == null ? "Nueva mascota" : "Editar mascota",
                style: TextStyle(color: AppColors.darkTeal, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => vm.seleccionarImagen(), 
                    child: CircleAvatar(
                      radius: 90,
                      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                      backgroundImage: vm.imagenEnBytes != null
                          ? MemoryImage(vm.imagenEnBytes!)
                          : (vm.urlImagenActual != null && vm.urlImagenActual!.isNotEmpty
                              ? NetworkImage(vm.urlImagenActual!) as ImageProvider
                              : null),
                      child: (vm.imagenEnBytes == null && (vm.urlImagenActual == null || vm.urlImagenActual!.isEmpty))
                          ? const Icon(Icons.add_a_photo, size: 40, color: AppColors.primaryGreen)
                          : null,
                    ),
                  ),
                  SizedBox(height: 30),
                  
                  TextoCampoInicio(
                    label: "Nombre",
                    hint: "Nombre de tu mascota",
                    icon: Icons.pets,
                    bgColor: AppColors.blancoTiza,
                    controller: vm.nombreController,
                    errorText: vm.nombreError,
                  ),
                  SizedBox(height: 16),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextoCampoInicio(
                          label: "Especie", 
                          hint: "Perro, Gato...", 
                          icon: Icons.category,
                          bgColor: AppColors.blancoTiza,
                          controller: vm.especieController,
                          errorText: vm.especieError,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextoCampoInicio(
                          label: "Peso (kg)", 
                          hint: "0.0", 
                          icon: Icons.monitor_weight_outlined,
                          bgColor: AppColors.blancoTiza,
                          controller: vm.pesoController,
                          errorText: vm.pesoError,
                          keyboardType: TextInputType.numberWithOptions(decimal: true), 
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  TextoCampoInicio(
                    label: "Raza", 
                    hint: "Ej: Golden Retriever", 
                    icon: Icons.info_outline,
                    bgColor: AppColors.blancoTiza,
                    controller: vm.razaController,
                    errorText: vm.razaError,
                  ),
                  SizedBox(height: 16),

                  TextoCampoInicio(
                    label: "Fecha de nacimiento", 
                    hint: "DD/MM/AAAA", 
                    icon: Icons.calendar_today,
                    bgColor: AppColors.blancoTiza,
                    controller: vm.fechaController,
                    onChanged: vm.formatearFecha,
                    errorText: vm.fechaError,
                    keyboardType: TextInputType.datetime, 
                  ),
                  SizedBox(height: 16),

                  TextoCampoInicio(
                    label: "Alergias (Opcional)", 
                    hint: "Indica si tiene alergias...", 
                    icon: Icons.warning_amber_rounded,
                    bgColor: AppColors.blancoTiza,
                    controller: vm.alergiasController,
                  ),
                  
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: vm.isLoading ? null : () {
                        String userId = mascotaAEditar?.idDueno ?? (vmCliente?.usuario?.id ?? "");
                        vm.guardar(
                          userId, 
                          exito: () {
                            if (vmCliente != null) vmCliente.cargarMascotas(); 
                            Navigator.pop(context, true);
                          }
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: vm.isLoading 
                        ?  SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2)
                          )
                        : Text(
                            mascotaAEditar == null ? "Registrar mascota" : "Guardar cambios", 
                            style:  TextStyle(
                              color: AppColors.white, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 16
                            )
                          ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}