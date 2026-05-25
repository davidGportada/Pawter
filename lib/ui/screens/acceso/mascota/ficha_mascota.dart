import 'package:flutter/material.dart';
import 'package:pawter/ui/screens/acceso/Agendar_Cita/agendar_cita_view.dart';
import 'package:pawter/ui/screens/acceso/Historial%20Clinico/historial_view.dart';
import 'package:pawter/widgets/mascota/pet_infofield.dart';
import 'package:provider/provider.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/ui/utils/app_colors.dart';
import 'package:pawter/ui/screens/acceso/cliente/cliente_viewmodel.dart';
import 'package:pawter/ui/screens/acceso/veterinario/vet_viewmodel.dart';
import 'package:pawter/ui/screens/acceso/mascota/creareditar_mascota.dart';

class FichaMascota extends StatelessWidget {
  final Mascota mascota;
  final int indice;
  final int total;
  final bool esVeterinario;

  const FichaMascota({
    super.key,
    required this.mascota,
    required this.indice,
    required this.total,
    this.esVeterinario = false,
  });

  @override
  Widget build(BuildContext context) {
    ClienteViewModel? vmCliente;
    try {
      vmCliente = context.read<ClienteViewModel>();
    } catch (_) {
      vmCliente = null;
    }

    Mascota mascotaAMostrar = mascota;
    if (esVeterinario) {
      final vmVet = context.watch<VeterinarioViewModel>();
      try {
        mascotaAMostrar = vmVet.pacientesFiltrados
            .firstWhere((p) => p.mascota.idMascota == mascota.idMascota)
            .mascota;
      } catch (_) {}
    } else {
      try {
        final vmCli = context.watch<ClienteViewModel>();
        mascotaAMostrar = vmCli.misMascotas
            .firstWhere((m) => m.idMascota == mascota.idMascota);
      } catch (_) {}
    }

    return Column(
      children: [
         SizedBox(height: 20),
        _construirCabecera(context, vmCliente, mascotaAMostrar),
         SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 10),
                _construirCuerpoInfo(context, vmCliente, mascotaAMostrar),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _construirCabecera(BuildContext context, ClienteViewModel? vm, Mascota mActual) {
    if (esVeterinario) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon:  Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkTeal, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                mActual.nombre,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primaryGreen, size: 26),
              onPressed: () async {
                final cambios = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CrearMascotaView(mascotaAEditar: mActual)),
                );
                if (cambios == true && context.mounted) {
                  context.read<VeterinarioViewModel>().cargarDirectorioCompleto();
                }
              },
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            indice > 0
                ? IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkTeal, size: 24),
                    onPressed: () {
                      vm?.detallesController.animateToPage(
                        indice - 1,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                  )
                : SizedBox(width: 48),

            Expanded(
              child: Text(
                mActual.nombre,
                textAlign: TextAlign.center,
                style:  TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
              ),
            ),

            IconButton(
              icon: Icon(Icons.arrow_forward_ios_rounded, color: AppColors.darkTeal, size: 24),
              onPressed: () {
                vm?.detallesController.animateToPage(
                  indice + 1,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ],
        ),
      );
    }
  }

  Widget _construirCuerpoInfo(BuildContext context, ClienteViewModel? vm, Mascota mActual) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow:  [
          BoxShadow(color: AppColors.black10, blurRadius: 20, offset: Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          _SeccionFotoMascota(mascota: mActual, vmCliente: vm, esVeterinario: esVeterinario),
          SizedBox(height: 24),
          PetInfoField(label: "Nombre:", value: mActual.nombre),
          Row(
            children: [
              Expanded(child: PetInfoField(label: "Especie:", value: mActual.especie)),
              SizedBox(width: 12),
              Expanded(child: PetInfoField(label: "Raza:", value: mActual.raza)),
            ],
          ),
          Row(
            children: [
              Expanded(child: PetInfoField(label: "Edad:", value: "${mActual.edad} años")),
              SizedBox(width: 12),
              Expanded(child: PetInfoField(label: "Peso:", value: "${mActual.peso} kg")),
            ],
          ),
          PetInfoField(
            label: "Alergias:",
            value: (mActual.alergias?.isEmpty ?? true) ? "Ninguna" : mActual.alergias!,
            isAlert: mActual.alergias != null && mActual.alergias!.isNotEmpty,
          ),
          SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Información de la mascota", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkTeal)),
          ),
          SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final cambio = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistorialMedicoView(mascota: mActual, esVeterinario: esVeterinario),
                ),
              );

              if (cambio == true && context.mounted) {
                if (esVeterinario) {
                  context.read<VeterinarioViewModel>().cargarDirectorioCompleto();
                } else {
                  context.read<ClienteViewModel>().cargarMascotas();
                }
              }
            },
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.black05),
              ),
              child: Row(
                children: [
                   Icon(Icons.assignment_ind_outlined, color: AppColors.primaryGreen, size: 28),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text("Ver historial clínico", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.darkTeal)),
                        Text("Registros, vacunas, urgencias...", style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                   Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 16),
                ],
              ),
            ),
          ),
          Divider(height: 40),
          _botonCita(context, vm, mActual),
        ],
      ),
    );
  }


  Widget _botonCita(BuildContext context, ClienteViewModel? vm, Mascota mActual) {
    final bool faltaPerfil = !esVeterinario && (vm != null && !vm.tienePerfilCompleto);

    return Column(
      children: [
        if (faltaPerfil)
          Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.lightRed, size: 18),
                SizedBox(width: 8),
                Text(
                  "Se requiere completar datos personales",
                  style: TextStyle(
                    color: AppColors.lightRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            // Desactivamos el botón si falta el perfil
            onPressed: faltaPerfil ? null : () async {
              final citado = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => AgendarCitaView(mascota: mActual)),
              );
              if (citado == true && context.mounted) {
                if (!esVeterinario) {
                  context.read<ClienteViewModel>().cargarProximaCita();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              disabledBackgroundColor: AppColors.lightGrey,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: Text("Agendar cita para ${mActual.nombre}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

class _SeccionFotoMascota extends StatelessWidget {
  final Mascota mascota;
  final ClienteViewModel? vmCliente;
  final bool esVeterinario;
  const _SeccionFotoMascota({required this.mascota, required this.vmCliente, required this.esVeterinario});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 70,
      backgroundColor: AppColors.primaryGreen10,
      backgroundImage: (mascota.fotoUrl != null && mascota.fotoUrl!.isNotEmpty) ? NetworkImage(mascota.fotoUrl!) : null,
      child: (mascota.fotoUrl == null || mascota.fotoUrl!.isEmpty) ? const Icon(Icons.pets, size: 60, color: AppColors.primaryGreen) : null,
    );
  }
}