import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/utils/app_colors.dart';
import 'package:pawter/ui/screens/acceso/cliente/cliente_viewmodel.dart';
import 'package:pawter/data/models/mascotas.dart';

class TarjetaProximaCita extends StatelessWidget {
  const TarjetaProximaCita({super.key});

  @override
  Widget build(BuildContext context) {
    final vistaModelo = context.watch<ClienteViewModel>();

    if (vistaModelo.estaCargando) return SizedBox(height: 100);
    
    if (vistaModelo.proximaCita == null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24), 
          border: Border.all(color: AppColors.black05)
        ),
        child: Text(
          "No tienes ninguna cita próxima.",
          textAlign: TextAlign.center, 
          style: TextStyle(color: AppColors.textGrey)
        ),
      );
    }

    final cita = vistaModelo.proximaCita!;
    Mascota? mascotaCita;
    try {
      mascotaCita = vistaModelo.misMascotas.firstWhere(
        (m) => m.idMascota.toString() == cita.idMascota.toString()
      );
    } catch (_) {}

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [
          BoxShadow(
            color: AppColors.black05, 
            blurRadius: 20, 
            offset: Offset(0, 10)
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryGreen10,
                  backgroundImage: (mascotaCita?.fotoUrl != null) 
                      ? NetworkImage(mascotaCita!.fotoUrl!) 
                      : null,
                  child: (mascotaCita?.fotoUrl == null) 
                      ? Icon(Icons.pets, color: AppColors.primaryGreen) 
                      : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${mascotaCita?.nombre ?? 'Mascota'} · ${cita.motivo}", 
                        style: TextStyle(
                          color: AppColors.darkTeal, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 16
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${vistaModelo.formatearFechaCita(cita.fechaHora)} a las ${vistaModelo.formatearHora(cita.fechaHora)}", 
                        style: TextStyle(color: AppColors.textGrey, fontSize: 14)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => vistaModelo.irACalendarioEnFecha(cita.fechaHora),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkTeal, 
                  foregroundColor: AppColors.white, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  "Gestionar en calendario", 
                  style: TextStyle(fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}