import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pawter/widgets/extras/usuario_menu.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/utils/app_colors.dart';
import 'package:pawter/ui/screens/acceso/cliente/cliente_viewmodel.dart';
import 'package:pawter/ui/screens/acceso/calendario/calendario_view.dart';
import 'package:pawter/widgets/mascota/mascota_detalles.dart';
import 'package:pawter/ui/screens/acceso/cliente/inicio_view.dart';

class ClienteHomeScreen extends StatelessWidget {
  const ClienteHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vmCliente = context.watch<ClienteViewModel>();

    final List<Widget> paginas = [
      const InicioView(), 
      const MascotaDetalles(),
      CalendarioView(fechaInicial: vmCliente.fechaDestinoCalendario),
      SizedBox(),
    ];

    return Scaffold(
      extendBody: false,
      bottomNavigationBar: _barraNav(context, vmCliente),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.bgGradientStart, AppColors.bgGradientEnd],
          ),
        ),
        child: paginas[vmCliente.indiceActual],
      ),
    );
  }

  Widget _barraNav(BuildContext context, ClienteViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
         BoxShadow(
            color: AppColors.black05, 
            blurRadius: 10, 
            offset: Offset(0, -2)
          )
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: vm.indiceActual,
        onTap: (indice) {
          if (indice == 3) {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => MenuPerfilCompartido(
                nombre: vm.usuario?.nombre ?? "Usuario",
                email: vm.usuario?.email ?? "",
                salir: () async {
                  Navigator.pop(context);
                  await vm.cerrarSesion();
                  if (context.mounted) context.go('/');
                },
              ),
            );
          } else {
            vm.actualizarIndice(indice);
          }
        },
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textGrey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Mascotas'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendario'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}