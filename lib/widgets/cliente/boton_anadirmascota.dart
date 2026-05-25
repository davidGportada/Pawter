import 'package:flutter/material.dart';
import 'package:pawter/ui/screens/acceso/mascota/creareditar_mascota.dart';
import 'package:pawter/ui/utils/app_colors.dart';

class BotonAnadirMascota extends StatelessWidget {
  const BotonAnadirMascota({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => const CrearMascotaView())
      ),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.transparent, 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: AppColors.black10, width: 1.5)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(Icons.add, color: AppColors.textGrey, size: 30), 
            SizedBox(height: 8),
            Text(
              "Nueva mascota", 
              style: TextStyle(
                color: AppColors.textGrey, 
                fontWeight: FontWeight.w600, 
                fontSize: 13
              )
            )
          ]
        ),
      ),
    );
  }
}