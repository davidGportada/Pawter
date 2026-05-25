import 'package:flutter/material.dart';
import 'package:pawter/ui/screens/acceso/mascota/ficha_mascota.dart';
import 'package:pawter/widgets/mascota/nueva_mascotacard.dart';
import 'package:provider/provider.dart';
import 'package:pawter/ui/screens/acceso/cliente/cliente_viewmodel.dart';

class MascotaDetalles extends StatelessWidget {
  const MascotaDetalles({super.key});

  @override
  Widget build(BuildContext context) {
    final vistaModelo = context.watch<ClienteViewModel>();
    final mascotas = vistaModelo.misMascotas;

    return PageView.builder(
      controller: vistaModelo.detallesController,

      physics: const NeverScrollableScrollPhysics(), 

      itemCount: mascotas.length + 1,
      itemBuilder: (context, indice) {
        if (indice < mascotas.length) {
          return FichaMascota(
            mascota: mascotas[indice],
            indice: indice,
            total: mascotas.length,
          );
        } else {
          return const TarjetaNuevaMascota();
        }
      },
    );
  }
}