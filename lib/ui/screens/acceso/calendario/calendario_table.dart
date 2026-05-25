import 'package:flutter/material.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/ui/screens/acceso/calendario/calendario_viewmodel.dart';
import 'package:pawter/ui/screens/acceso/cliente/cliente_viewmodel.dart';
import 'package:pawter/ui/screens/acceso/veterinario/vet_viewmodel.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/utils/app_colors.dart';

class CalendarioTable extends StatelessWidget {
  const CalendarioTable({super.key});

  @override
  Widget build(BuildContext context) {
    final vmCitas = context.watch<CalendarioViewModel>();

    List<Mascota> listaMascotas = [];
    if (vmCitas.esVeterinario) {
      try {
        final vmVet = context.watch<VeterinarioViewModel>();
        listaMascotas = vmVet.pacientesFiltrados.map((p) => p.mascota).toList();
      } catch (_) {}
    } else {
      try {
        final vmCliente = context.watch<ClienteViewModel>();
        listaMascotas = vmCliente.misMascotas;
      } catch (_) {}
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: TableCalendar(
        locale: 'es_ES',
        firstDay: DateTime.utc(2026, 1, 1),
        lastDay: DateTime.utc(2099, 12, 31),
        focusedDay: vmCitas.diaActual,
        selectedDayPredicate: (day) => isSameDay(vmCitas.diaElegido, day),
        onDaySelected: vmCitas.diaSeleccionado,
        startingDayOfWeek: StartingDayOfWeek.monday,
        rowHeight: 60,

        calendarStyle: const CalendarStyle(outsideDaysVisible: false),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: AppColors.darkTeal,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          leftChevronIcon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.darkTeal,
            size: 16,
          ),
          rightChevronIcon: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.darkTeal,
            size: 16,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
          weekendStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) =>
              _constrCeldaDia(day, vmCitas, listaMascotas),
          todayBuilder: (context, day, focusedDay) =>
              _constrCeldaDia(day, vmCitas, listaMascotas, esHoy: true),
          selectedBuilder: (context, day, focusedDay) =>
              _constrCeldaDia(day, vmCitas, listaMascotas, seleccionado: true),
        ),
      ),
    );
  }

  Widget _constrCeldaDia(
    DateTime fecha,
    CalendarioViewModel vmcalendario,
    List<Mascota> mascotas, {
    bool seleccionado = false,
    bool esHoy = false,
  }) {
    final hayMascota = vmcalendario.tieneCita(fecha);
    final imagenMascota = vmcalendario.obtenerFotoMascotaParaDia(fecha, mascotas);

    return Container(
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: seleccionado ? Colors.grey[200] : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: seleccionado ? AppColors.primaryGreen : Colors.grey[300]!,
          width: seleccionado ? 2 : 1,
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: hayMascota
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${fecha.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTeal,
                      ),
                    ),
                    SizedBox(height: 2),
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.primaryGreen,
                      backgroundImage:
                          (imagenMascota != null && imagenMascota.isNotEmpty)
                          ? NetworkImage(imagenMascota)
                          : null,
                      child: (imagenMascota == null || imagenMascota.isEmpty)
                          ? const Icon(
                              Icons.pets,
                              size: 12,
                              color: AppColors.white,
                            )
                          : null,
                    ),
                  ],
                )
              : Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '${fecha.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: esHoy ? FontWeight.bold : FontWeight.normal,
                      color: AppColors.darkTeal,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
