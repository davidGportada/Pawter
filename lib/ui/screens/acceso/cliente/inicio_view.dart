import 'package:flutter/material.dart';
import 'package:pawter/widgets/cliente/boton_anadirmascota.dart';
import 'package:pawter/widgets/cliente/noticia.dart';
import 'package:pawter/widgets/cliente/tarjeta_proximacita.dart';
import 'package:pawter/widgets/mascota/mascota_card.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/utils/app_colors.dart';
import 'package:pawter/ui/screens/acceso/cliente/cliente_viewmodel.dart';

class InicioView extends StatelessWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context) {
    final vmCliente = context.watch<ClienteViewModel>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32),
              Text(
                "Panel de control",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTeal,
                ),
              ),
              SizedBox(height: 16),
              const TarjetaProximaCita(),
              SizedBox(height: 40),

              Text(
                "Mascotas registradas",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTeal,
                ),
              ),
              SizedBox(height: 16),
              vmCliente.estaCargando
                  ? Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGreen))
                  : SizedBox(
                      height: 160,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          ...vmCliente.misMascotas.map(
                            (mascota) => Padding(
                              padding: EdgeInsets.only(right: 16.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () =>
                                    vmCliente.seleccionarMascota(mascota),
                                child: MascotaCard(
                                  nombre: mascota.nombre,
                                  raza: mascota.raza,
                                  icon: Icons.pets,
                                  edad: mascota.edad,
                                  peso: mascota.peso,
                                  alergias: mascota.alergias,
                                  fotoURL: mascota.fotoUrl,
                                ),
                              ),
                            ),
                          ),
                          const BotonAnadirMascota(),
                        ],
                      ),
                    ),

              SizedBox(height: 40),

             Text(
                "Noticias",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTeal,
                ),
              ),
              SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: noticias.length,
                itemBuilder: (context, index) =>
                    NoticiaCard(noticia: noticias[index]),
              ),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}