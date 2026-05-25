import 'package:flutter/material.dart';
import 'package:pawter/ui/utils/app_colors.dart';

class TextoCampoInicio extends StatefulWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final Color bgColor;
  final bool isPassword;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? errorText;
  final TextInputType keyboardType;
  final int? maxLines;

  const TextoCampoInicio({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    required this.bgColor,
    this.isPassword = false,
    this.controller,
    this.onChanged,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  State<TextoCampoInicio> createState() => _TextoCampoInicioState();
}

class _TextoCampoInicioState extends State<TextoCampoInicio> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? !_isPasswordVisible : false,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(
          color: AppColors.textGrey,
          fontSize: 16,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        hintText: widget.hint,
        hintStyle: const TextStyle(
          color: AppColors.textGrey,
          fontSize: 14,
        ),
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: AppColors.textGrey)
            : null,

        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColors.textGrey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,

        filled: true,
        fillColor: widget.bgColor,
        errorText: widget.errorText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.black10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.black10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.lightRed,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.lightRed,
            width: 2,
          ),
        ),
      ),
    );
  }
}