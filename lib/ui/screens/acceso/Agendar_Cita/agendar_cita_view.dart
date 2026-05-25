import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/ui/utils/app_colors.dart';
import 'agendar_cita_viewmodel.dart';

class AgendarCitaView extends StatelessWidget {
  final Mascota mascota;
  const AgendarCitaView({super.key, required this.mascota});

  @override
  Widget build(BuildContext context) {
    final String idUsuario = mascota.idDueno;

    return ChangeNotifierProvider(
      create: (_) =>
          AgendarCitaViewModel(mascota: mascota, idUsuario: idUsuario),
      child: Consumer<AgendarCitaViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: AppColors.blancoTiza,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: AppColors.darkTeal),
              onPressed: vm.estaCargando ? null : () => Navigator.pop(context),
            ),
            title: Text(
              "Cita para ${mascota.nombre}",
              style: TextStyle(
                color: AppColors.darkTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: TableCalendar(
                    locale: 'es_ES',
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(Duration(days: 90)),
                    focusedDay: vm.diaActual,
                    selectedDayPredicate: (day) => isSameDay(vm.elegirDia, day),
                    onDaySelected: vm.estaCargando ? null : vm.diaSelecionado,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Mes',
                    },
                    headerStyle: HeaderStyle(
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
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      defaultTextStyle: TextStyle(color: AppColors.darkTeal),
                      weekendTextStyle: TextStyle(color: AppColors.darkTeal),
                      selectedDecoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                const Text(
                  "Horas disponibles",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTeal,
                  ),
                ),
                SizedBox(height: 16),
                if (vm.estaCargando)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  )
                else if (vm.mascotaTieneCita)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightRed,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.lightRed),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Ya hay una cita con ${mascota.nombre} este día. \nPor favor, selecciona otra fecha.",
                            style: TextStyle(
                              color: Colors.white,
                              
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (vm.horasDisponibles.isEmpty)
                  Text(
                    "No quedan huecos disponibles para este día.",
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: vm.horasDisponibles.map((hora) {
                      bool isSelected = vm.horaSeleccionada == hora;
                      return ChoiceChip(
                        label: Text(
                          hora,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.blancoTiza
                                : AppColors.darkTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primaryGreen,
                        backgroundColor: AppColors.white,
                        onSelected: vm.estaCargando
                            ? null
                            : (_) => vm.seleccionarHora(hora),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      );
                    }).toList(),
                  ),
                SizedBox(height: 30),
                Text(
                  "Motivo de la visita",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTeal,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: vm.motivoCitaController,
                  style: TextStyle(color: AppColors.darkTeal),
                  maxLines: 3,
                  enabled: !vm.mascotaTieneCita && !vm.estaCargando,
                  decoration: InputDecoration(
                    hintText: "Ej: Revisión anual, vacuna...",
                    filled: true,
                    fillColor: (vm.mascotaTieneCita || vm.estaCargando)
                        ? Colors.grey.shade200
                        : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                        (vm.estaCargando ||
                            vm.horaSeleccionada == null ||
                            vm.motivoCitaController.text.isEmpty ||
                            vm.mascotaTieneCita)
                        ? null
                        : () {
                            vm.agendarCita(
                              onSuccess: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Se ha apuntado la cita",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor: AppColors.primaryGreen,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                                Navigator.pop(context, true);
                              },
                              onError: (mensaje) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      mensaje,
                                      textAlign: TextAlign.center,
                                    ),
                                    backgroundColor: AppColors.lightRed,
                                  ),
                                );
                              },
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      disabledBackgroundColor: AppColors.lightGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: vm.estaCargando ? 0 : 2,
                    ),
                    child: vm.estaCargando
                        ? Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          )
                        : Text(
                            "Confirmar cita",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
