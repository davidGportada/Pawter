import 'package:flutter/material.dart';
import 'package:pawter/ui/utils/app_colors.dart';

class PetInfoField extends StatelessWidget {
  final String label;
  final String value;
  final bool isAlert;

  const PetInfoField({
    super.key,
    required this.label,
    required this.value,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isAlert ? AppColors.lightRed : AppColors.darkTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}