import 'package:flutter/material.dart';
import 'package:pawter/ui/utils/app_colors.dart'; 

class SigCitaCard extends StatelessWidget {
  final String fecha;
  final String motivo;
  final String veterinario;

  const SigCitaCard({
    super.key,
    required this.fecha,
    required this.motivo,
    required this.veterinario,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black05,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryGreen,
                child: Icon(
                  Icons.notifications_active,
                  color: AppColors.white,
                  size: 30,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Próxima cita",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.darkTeal,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "$motivo - $fecha",
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      "Vet: $veterinario",
                      style: TextStyle(
                        color: AppColors.textGrey, 
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkTeal,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Ver detalles",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}