import 'package:flutter/material.dart';
import 'package:pawter/ui/utils/app_colors.dart';

class CalendarioNoCitaCard extends StatelessWidget {
  const CalendarioNoCitaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.black05),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 40,
            color: AppColors.darkTeal10, 
          ),
          SizedBox(height: 16),
          Text(
            "Día libre",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTeal,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "No tienes citas programadas para hoy.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}