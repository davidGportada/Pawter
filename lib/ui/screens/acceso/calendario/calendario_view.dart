import 'package:flutter/material.dart';
import 'package:pawter/ui/screens/acceso/cliente/cliente_viewmodel.dart';
import 'package:pawter/ui/screens/acceso/veterinario/vet_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/utils/app_colors.dart';
import 'package:pawter/data/models/citas.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/ui/screens/acceso/calendario/calendario_table.dart';
import 'package:pawter/ui/screens/acceso/calendario/calendario_viewmodel.dart';
import 'package:pawter/widgets/lasCitas/calendario_citacard.dart';
import 'package:pawter/widgets/lasCitas/calendario_sincitacard.dart';

class CalendarioView extends StatelessWidget {
  final DateTime? fechaInicial;
  final bool esVeterinario;
  const CalendarioView({super.key, this.fechaInicial, this.esVeterinario = false});
  @override
  Widget build(BuildContext context) {
    String? idUsuario;
    if (!esVeterinario) {
      idUsuario = context.read<ClienteViewModel>().usuario?.id;
    }

    return ChangeNotifierProvider(
      create: (_) {
        final vmCalendario = CalendarioViewModel(fechaInicial: fechaInicial, esVeterinario: esVeterinario);
        vmCalendario.cargarDatos(idUsuario);
        return vmCalendario;
      },
      child: const _Calendario(), 
    );
  }
}

class _Calendario extends StatelessWidget {
  const _Calendario();

  @override
  Widget build(BuildContext context) {
    final vmCalendario = context.watch<CalendarioViewModel>();
    List<Mascota> directorioMascotas = [];
    if (vmCalendario.esVeterinario) {
      final vmVet = context.read<VeterinarioViewModel>();
      directorioMascotas = vmVet.pacientesFiltrados.map((p) => p.mascota).toList();
    } else {
      directorioMascotas = context.read<ClienteViewModel>().misMascotas;
    }

    final DateTime diaSelUTC = DateTime.utc(
      vmCalendario.diaElegido.year, 
      vmCalendario.diaElegido.month, 
      vmCalendario.diaElegido.day
    );
    final List<Cita> citasDelDia = vmCalendario.citasReales[diaSelUTC] ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              const CalendarioTable(),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Eventos del día",
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.darkTeal
                  ),
                ),
              ),
              SizedBox(height: 12),
              citasDelDia.isNotEmpty 
                  ? Column(
                      children: citasDelDia.map((cita) {
                        Mascota? mascota;
                        try {
                          mascota = directorioMascotas.firstWhere(
                            (m) => m.idMascota.toString() == cita.idMascota.toString()
                          );
                        } catch (_) {}

                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: CalendarioCitaCard(
                            cita: cita, 
                            mascota: mascota, 
                            esVeterinario: vmCalendario.esVeterinario
                          ),
                        );
                      }).toList(),
                    )
                  : const CalendarioNoCitaCard(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}