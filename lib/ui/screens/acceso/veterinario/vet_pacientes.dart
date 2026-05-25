import 'package:flutter/material.dart';
import 'package:pawter/ui/screens/acceso/veterinario/Ficha_cliente/ficha_clienteview.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/utils/app_colors.dart';
import 'package:pawter/widgets/texto_field.dart';
import 'package:pawter/ui/screens/acceso/veterinario/vet_viewmodel.dart';
import 'package:pawter/ui/screens/acceso/mascota/ficha_mascota.dart';

class VetPacientesTab extends StatelessWidget {
  const VetPacientesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VeterinarioViewModel>();

    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: 24),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _botonTab(
                  label: "Mascotas",
                  icon: Icons.pets,
                  isActive: vm.viendoMascotas,
                  onTap: () => vm.cambiarVistaPacientes(true),
                ),
                SizedBox(width: 12),
                _botonTab(
                  label: "Clientes",
                  icon: Icons.people_alt_rounded,
                  isActive: !vm.viendoMascotas,
                  onTap: () => vm.cambiarVistaPacientes(false),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextoCampoInicio(
                    label: vm.viendoMascotas
                        ? "Nombre de la mascota"
                        : "Nombre del cliente",
                    hint: vm.viendoMascotas ? "Diana" : "David",
                    bgColor: AppColors.white,
                    onChanged: (val) => vm.aplicarFiltros(nombre: val),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextoCampoInicio(
                    label: "Email",
                    hint: "...@mail.com",
                    bgColor: AppColors.white,
                    onChanged: (val) => vm.aplicarFiltros(email: val),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          Expanded(
            child: vm.cargando
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  )
                : (vm.viendoMascotas
                    ? _buildListaMascotas(vm)
                    : _buildListaClientes(vm)),
          ),
        ],
      ),
    );
  }

  Widget _botonTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGreen : AppColors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isActive ? AppColors.primaryGreen : AppColors.black10,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryGreen20,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.white : AppColors.textGrey,
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.white : AppColors.textGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListaMascotas(VeterinarioViewModel vm) {
    if (vm.pacientesFiltrados.isEmpty) {
      return Center(
        child: Text(
          "No se encontraron mascotas",
          style: TextStyle(color: AppColors.textGrey),
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: vm.pacientesFiltrados.length,
      itemBuilder: (context, index) {
        final item = vm.pacientesFiltrados[index];
        return Card(
          elevation: 0,
          color: AppColors.white,
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primaryGreen10,
              backgroundImage:
                  (item.mascota.fotoUrl != null &&
                          item.mascota.fotoUrl!.isNotEmpty)
                      ? NetworkImage(item.mascota.fotoUrl!)
                      : null,
              child:
                  (item.mascota.fotoUrl == null ||
                          item.mascota.fotoUrl!.isEmpty)
                      ? Icon(Icons.pets, color: AppColors.primaryGreen)
                      : null,
            ),
            title: Text(
              item.mascota.nombre,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkTeal,
              ),
            ),
            subtitle: Text("${item.mascota.especie} • ${item.dueno.email}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    backgroundColor: AppColors.blancoTiza,
                    body: SafeArea(
                      child: FichaMascota(
                        mascota: item.mascota,
                        indice: 0,
                        total: 1,
                        esVeterinario: true,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildListaClientes(VeterinarioViewModel vm) {
    if (vm.clientesFiltrados.isEmpty) {
      return Center(
        child: Text(
          "No se encontraron clientes",
          style: TextStyle(color: AppColors.textGrey),
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: vm.clientesFiltrados.length,
      itemBuilder: (context, index) {
        final cliente = vm.clientesFiltrados[index];

        final bool faltanDatos =
            (cliente.dni?.isEmpty ?? true) ||
            (cliente.direccion?.isEmpty ?? true) ||
            (cliente.telefono?.isEmpty ?? true);

        return Card(
          elevation: 0,
          color: AppColors.white,
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primaryGreen10,
              child: Icon(Icons.person, color: AppColors.darkTeal),
            ),
            title: Text(
              cliente.nombre,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkTeal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cliente.email, style: TextStyle(fontSize: 13)),
                if (faltanDatos) ...[
                  SizedBox(height: 4),
                  Text(
                    "Falta verificación",
                    style: TextStyle(
                      color: AppColors.lightRed,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FichaClienteView(cliente: cliente),
                ),
              ).then((_) {
                vm.cargarTodosLosClientes();
              });
            },
          ),
        );
      },
    );
  }
}