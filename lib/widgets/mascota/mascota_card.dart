import 'package:flutter/material.dart';
import 'package:pawter/ui/utils/app_colors.dart';

class MascotaCard extends StatelessWidget {
  final String nombre;
  final String raza;
  final IconData icon;
  final int edad;
  final double peso;
  final String? alergias;
  final String? fotoURL;

  const MascotaCard({
    super.key,
    required this.nombre,
    required this.raza,
    required this.icon,
    required this.edad,
    required this.peso,
    this.alergias,
    required this.fotoURL,
  });

  @override
  Widget build(BuildContext context) {
    bool tieneAlergias = alergias != null && alergias!.trim().isNotEmpty;
    String txtAlergias = tieneAlergias ? "Tiene alergias" : "Sin alergias";

    return Container(
      width: 140,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black05,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.lightGrey,
                backgroundImage: (fotoURL != null && fotoURL!.isNotEmpty) 
                    ? NetworkImage(fotoURL!) 
                    : null,
                child: (fotoURL == null || fotoURL!.isEmpty) 
                    ? Icon(icon, size: 25, color: AppColors.textGrey) 
                    : null,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTeal,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text("Edad: $edad años", style: const TextStyle(color: AppColors.darkTeal, fontSize: 13)),
          SizedBox(height: 4),
          Text("Peso: ${peso.toInt()} kg", style: const TextStyle(color: AppColors.darkTeal, fontSize: 13)),
          SizedBox(height: 4),
          Text(
            txtAlergias,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tieneAlergias ? AppColors.lightRed : AppColors.darkTeal,
            ),
          ),
        ],
      ),
    );
  }
}