import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/utils/app_colors.dart';
import 'package:pawter/data/models/citas.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/ui/screens/acceso/calendario/calendario_viewmodel.dart';
import 'package:pawter/ui/screens/acceso/cliente/cliente_viewmodel.dart';

class CalendarioCitaCard extends StatelessWidget {
  final Cita cita;
  final Mascota? mascota;
  final bool esVeterinario;

  const CalendarioCitaCard({
    super.key,
    required this.cita,
    this.mascota,
    this.esVeterinario = false,
  });

  String _formatearHoraLocal(DateTime fecha) {
    String tramo = fecha.hour >= 12 ? "PM" : "AM";
    int hora12 = fecha.hour % 12;
    if (hora12 == 0) hora12 = 12;
    return "$hora12:${fecha.minute.toString().padLeft(2, '0')} $tramo";
  }

  @override
  Widget build(BuildContext context) {
    String horaFormateada = _formatearHoraLocal(cita.fechaHora);
    final bool haPasado = cita.fechaHora.isBefore(DateTime.now());

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: haPasado ? AppColors.lightGrey : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black05,
            blurRadius: 15,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryGreen10,
            backgroundImage: (mascota?.fotoUrl != null && mascota!.fotoUrl!.isNotEmpty)
                ? NetworkImage(mascota!.fotoUrl!)
                : null,
            child: (mascota?.fotoUrl == null || mascota!.fotoUrl!.isEmpty)
                ? const Icon(Icons.pets, color: AppColors.primaryGreen, size: 28)
                : null,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mascota?.nombre ?? "Paciente",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16, 
                    color: AppColors.darkTeal
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  cita.motivo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: AppColors.primaryGreen),
                    SizedBox(width: 4),
                    Text(
                      horaFormateada,
                      style: const TextStyle(
                        color: AppColors.primaryGreen, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 12
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if (!haPasado)
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.lightRed.withValues(alpha: 0.1),
                  foregroundColor: AppColors.lightRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => _mostrarDialogoEliminar(context),
                child: const Text(
                  "Eliminar", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Cancelar cita", style: TextStyle(color: AppColors.darkTeal, fontWeight: FontWeight.bold)),
          content: const Text("¿Estás seguro de que deseas cancelar esta cita?", style: TextStyle(color: AppColors.textGrey)),
          actions: [
            TextButton(
              child: const Text("Volver", style: TextStyle(color: AppColors.textGrey)),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightRed,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Confirmar", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await context.read<CalendarioViewModel>().eliminarCita(cita);
                
                if (context.mounted) {
                  if (!esVeterinario) {
                    context.read<ClienteViewModel>().cargarProximaCita();
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "La cita se ha eliminado correctamente",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: AppColors.primaryGreen,
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}