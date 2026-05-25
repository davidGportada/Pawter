import 'package:flutter/material.dart';
import 'package:pawter/ui/screens/ResetContrase%C3%B1a/recuperar_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:pawter/widgets/texto_field.dart';
import 'package:pawter/ui/utils/app_colors.dart';

class RecuperarPasswordScreen extends StatelessWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecuperarPasswordViewModel(),
      child: _RecuperarPassword(),
    );
  }
}

class _RecuperarPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecuperarPasswordViewModel>();
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.darkTeal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgGradientStart, AppColors.bgGradientEnd],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(color: AppColors.black05, blurRadius: 20, offset: Offset(0, 10)),
                  ],
                ),
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_reset, size: 80, color: AppColors.primaryGreen),
                    SizedBox(height: 16),
                    Text(
                      'Recuperar contraseña',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Te enviaremos un enlace a tu correo para que puedas restablecer la contraseña',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                    SizedBox(height: 32),
                    
                    TextoCampoInicio(
                      label: 'Correo electrónico',
                      hint: 'Email',
                      icon: Icons.mail_outline,
                      bgColor: AppColors.lightGrey,
                      onChanged: viewModel.onEmailChange,
                      errorText: viewModel.emailError,
                    ),
                    SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : () => _enviar(context, viewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 0,
                        ),
                        child: viewModel.isLoading
                            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 3))
                            : Text('Pedir email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _enviar(BuildContext context, RecuperarPasswordViewModel vm) {
    vm.onSubmit(
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Enviado, mira tu bandeja de entrada"), 
            backgroundColor: AppColors.primaryGreen
          ),
        );
        Navigator.pop(context);
      },
      onError: (msg) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg), 
            backgroundColor: AppColors.lightRed
          ),
        );
      },
    );
  }
}