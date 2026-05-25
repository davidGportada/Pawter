import 'package:flutter/material.dart';
import 'package:pawter/ui/screens/acceso/Agendar_Cita/franja_horas.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/utils/app_colors.dart';
import 'package:pawter/ui/screens/acceso/veterinario/vet_viewmodel.dart';
import 'package:pawter/ui/screens/acceso/Historial%20Clinico/historial_view.dart';
import 'package:pawter/data/models/mascotas.dart';

class VetDashboard extends StatelessWidget {
  const VetDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final vmVet = context.watch<VeterinarioViewModel>();
    return SafeArea(
      child: Column(
        children: [
          _buildCabecera(vmVet),
          Expanded(
            child: vmVet.cargando
                ? Center(child: CircularProgressIndicator(color: AppColors.darkTeal))
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(top: 10, bottom: 40),
                    children: _buildAgenda(context, vmVet),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAgenda(BuildContext context, VeterinarioViewModel vm) {
    List<String> horas = FranjaHorario.getFranjaHoraria();
    List<Widget> widgets = [];

    widgets.add(_buildLineaTiempo("", isFirst: true, isDotActive: false, content: _buildLineaSimple()));

    for (int i = 0; i < horas.length; i++) {
      String horaActual = horas[i];
      if (i > 0 && horas[i - 1] == "13:30" && horaActual == "16:00") {
        widgets.add(_buildLineaTiempo("", isDotActive: false, content: _buildSeparador("Almuerzo / Descanso")));
      }

      Widget tarjeta;
      bool hayCita = vm.agendaMap.containsKey(horaActual);

      if (hayCita) {
        var datosCita = vm.agendaMap[horaActual];
        
        tarjeta = _buildCitaOcupada(
          datosCita['nombre'] ?? 'Paciente', 
          datosCita['motivo'] ?? 'Consulta', 
          datosCita['foto'] ?? '',
          onTap: () {
            Mascota? mascotaCita;
            try {
              if (datosCita['idMascota'] != null) {
                final idBuscado = datosCita['idMascota'].toString();
                final pacienteInfo = vm.pacientesFiltrados.firstWhere(
                  (p) => p.mascota.idMascota.toString() == idBuscado,
                );
                mascotaCita = pacienteInfo.mascota;
              }
            } catch (e) {
              debugPrint("Mascota no encontrada: $e");
            }

            if (mascotaCita != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistorialMedicoView(
                    mascota: mascotaCita!,
                    esVeterinario: true,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('No se encontró la ficha de la mascota'),
                  backgroundColor: AppColors.lightRed,
                ),
              );
            }
          }
        );
      } else {
        tarjeta = _buildCitaDisponible(); 
      }
      widgets.add(_buildLineaTiempo(horaActual, isDotActive: hayCita, content: tarjeta));
    }

    widgets.add(_buildLineaTiempo("", isLast: true, isDotActive: false, content: _buildSeparador("Fin de jornada")));
    return widgets;
  }

  Widget _buildCabecera(VeterinarioViewModel vm) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          SizedBox(height: 10),
          Text(
            "Agenda", 
            style:  TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(color: AppColors.darkTeal, borderRadius: BorderRadius.circular(25)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                vm.mostrarHoy 
                  ? SizedBox(width: 48) 
                  : IconButton(
                      icon:  Icon(Icons.chevron_left, color: AppColors.white),
                      onPressed: () => vm.cambiarDia(true),
                    ),
                
                Text(
                  vm.mostrarHoy ? "Hoy" : "Mañana",
                  style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),

                !vm.mostrarHoy 
                  ? SizedBox(width: 48) 
                  : IconButton(
                      icon: Icon(Icons.chevron_right, color: AppColors.white),
                      onPressed: () => vm.cambiarDia(false),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineaTiempo(String time, {required Widget content, bool isFirst = false, bool isLast = false, bool isDotActive = true}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Padding(
              padding: EdgeInsets.only(top: 25, right: 10),
              child: Text(time, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkTeal, fontSize: 14)),
            ),
          ),
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Expanded(child: Container(width: 2, color: isFirst ? Colors.transparent : AppColors.primaryGreen20)),
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: isDotActive ? AppColors.darkTeal : AppColors.primaryGreen20,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : AppColors.primaryGreen20)),
              ],
            ),
          ),
          Expanded(child: Padding(padding: EdgeInsets.only(left: 15, right: 20, bottom: 15), child: content)),
        ],
      ),
    );
  }

  Widget _buildCitaOcupada(String nombre, String motivo, String urlFoto, {required VoidCallback onTap}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow:  [BoxShadow(color: AppColors.black05, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25, 
            backgroundColor: AppColors.lightGrey, 
            backgroundImage: urlFoto.isNotEmpty ? NetworkImage(urlFoto) : null,
            child: urlFoto.isEmpty ?  Icon(Icons.pets, color: AppColors.textGrey) : null,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nombre, 
                  style:  TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  motivo, 
                  style:  TextStyle(fontSize: 13, color: AppColors.textGrey),
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon:  Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primaryGreen, size: 20),
            onPressed: onTap,
            constraints: BoxConstraints(),
            padding: EdgeInsets.only(left: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildCitaDisponible() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.successGreenBg,
        border: Border.all(color: AppColors.primaryGreen20, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Text(
            "Hora disponible", 
            style: TextStyle(color: AppColors.darkTeal.withValues(alpha: 0.8), fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }

  Widget _buildLineaSimple() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(height: 1, width: 100, color: AppColors.primaryGreen20),
    );
  }

  Widget _buildSeparador(String texto) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.primaryGreen20)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(texto, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
        ),
        Expanded(child: Container(height: 1, color: AppColors.primaryGreen20)),
      ],
    );
  }
}