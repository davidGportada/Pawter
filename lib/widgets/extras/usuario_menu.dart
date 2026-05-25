import 'package:flutter/material.dart';
import 'package:pawter/ui/utils/app_colors.dart';

class MenuPerfilCompartido extends StatelessWidget {
  final String nombre;
  final String email;
  final VoidCallback salir;

  const MenuPerfilCompartido({
    super.key,
    required this.nombre,
    required this.email,
    required this.salir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryGreen10,
                child: Icon(Icons.person, color: AppColors.primaryGreen, size: 30),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18, 
                        color: AppColors.darkTeal
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Divider(color: AppColors.black05),
          SizedBox(height: 8),
          InkWell(
            onTap: salir,
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  Icon(Icons.logout, color: AppColors.lightRed),
                  SizedBox(width: 12),
                  Text(
                    "Cerrar sesión",
                    style: TextStyle(
                      color: AppColors.lightRed, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}