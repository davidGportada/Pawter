import 'package:flutter/material.dart';
import 'package:pawter/ui/screens/acceso/veterinario/vet_view.dart';
import 'package:pawter/ui/screens/acceso/veterinario/vet_pacientes.dart';
import 'package:pawter/ui/screens/acceso/veterinario/vet_viewmodel.dart';
import 'package:pawter/widgets/extras/usuario_menu.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/utils/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:pawter/ui/screens/acceso/calendario/calendario_view.dart';

class VeterinarioHomeScreen extends StatefulWidget {
  const VeterinarioHomeScreen({super.key});

  @override
  State<VeterinarioHomeScreen> createState() => _VeterinarioHomeScreenState();
}

class _VeterinarioHomeScreenState extends State<VeterinarioHomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final vmVet = context.watch<VeterinarioViewModel>();
    final List<Widget> paginas = [
      const VetDashboard(),
      const VetPacientesTab(),
      const CalendarioView(esVeterinario: true),
    ];

    return Scaffold(
      extendBody: false,
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
        child: paginas[vmVet.indiceSeleccionado],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: vmVet.indiceSeleccionado,
          onTap: (indice) {
            if (indice == 3) {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => MenuPerfilCompartido(
                  nombre: vmVet.nombreVet,
                  email: vmVet.usuario?.email ?? "veterinario@pawter.com",
                  salir: () async {
                    Navigator.pop(context);
                    await vmVet.cerrarSesion();
                    if (context.mounted) context.go('/');
                  },
                ),
              );
            } else {
              vmVet.actualizarIndice(indice);
            }
          },
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: Colors.grey[600],
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Pacientes'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendario'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}