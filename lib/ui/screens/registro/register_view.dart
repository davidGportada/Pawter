import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pawter/ui/home/navhost.dart';
import 'package:pawter/ui/screens/registro/register_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:pawter/widgets/texto_field.dart';
import 'package:pawter/data/models/usuarios.dart';
import 'package:pawter/ui/utils/app_colors.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegisterViewModel>();
    final state = viewModel.state;

    return Scaffold(
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
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black05,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Crear cuenta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTeal,
                      ),
                    ),
                    SizedBox(height: 32),

                    TextoCampoInicio(
                      label: 'Nombre completo',
                      hint: 'Nombre',
                      icon: Icons.person_outline,
                      bgColor: AppColors.lightGrey,
                      onChanged: viewModel.onNombreChange,
                      errorText: state.nombreError,
                    ),
                    SizedBox(height: 16),

                    TextoCampoInicio(
                      label: 'Correo electrónico',
                      hint: 'Email',
                      icon: Icons.mail_outline,
                      bgColor: AppColors.lightGrey,
                      onChanged: viewModel.onEmailChange,
                      errorText: state.emailError,
                    ),
                    SizedBox(height: 16),

                    TextoCampoInicio(
                      label: 'Contraseña',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      bgColor: AppColors.lightGrey,
                      onChanged: viewModel.onPasswordChange,
                      errorText: state.passwordError,
                    ),
                    SizedBox(height: 16),

                    TextoCampoInicio(
                      label: 'Confirmar contraseña',
                      hint: '••••••••',
                      icon: Icons.lock_reset,
                      isPassword: true,
                      bgColor: AppColors.lightGrey,
                      onChanged: viewModel.onConfirmPasswordChange,
                      errorText: state.confirmPasswordError,
                    ),
                    SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state.isLoading 
                          ? null 
                          : () {
                              viewModel.onRegisterSubmit(
                                onSuccess: (Usuario nuevoUsuario) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("Cuenta creada. Revisa tu email para poder logear."),
                                      backgroundColor: AppColors.primaryGreen,
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                  context.go(AppRoutes.login);
                                },
                                onError: (String errorMsg) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorMsg),
                                      backgroundColor: AppColors.lightRed,
                                    ),
                                  );
                                }
                              );
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: state.isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                'Registrarse',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        context.go(AppRoutes.login);
                      },
                      child: Text(
                        '¿Ya tienes cuenta? Inicia sesión',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primaryGreen,
                        ),
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
}