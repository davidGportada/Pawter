import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pawter/data/models/enums/rol_usuario.dart';
import 'package:pawter/ui/home/navhost.dart';
import 'package:pawter/ui/screens/ResetContrase%C3%B1a/recuperar_view.dart';
import 'package:pawter/ui/screens/acceso/cliente/cliente_viewmodel.dart';
import 'package:pawter/ui/screens/login/login_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:pawter/widgets/texto_field.dart';
import 'package:pawter/data/models/usuarios.dart';
import 'package:pawter/ui/utils/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final state = viewModel.state;

    return Scaffold(
      body: Container(
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
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 60.0),
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
                    padding: EdgeInsets.only(
                      top: 80.0,
                      left: 32.0,
                      right: 32.0,
                      bottom: 32.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Inicio de sesión',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTeal,
                          ),
                        ),
                        SizedBox(height: 32),

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
                        SizedBox(height: 24),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RecuperarPasswordScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Olvidé mi contraseña',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: state.isLoading
                                ? null
                                : () {
                                    viewModel.onLoginSubmit(
                                      onSuccess: (Usuario usuarioLogueado) {
                                        if (usuarioLogueado.rol ==
                                            RolUsuario.cliente) {
                                          context
                                              .read<ClienteViewModel>()
                                              .establecerUsuario(
                                                usuarioLogueado,
                                              );
                                          context.go(AppRoutes.cliente);
                                        } else {
                                          context.go(AppRoutes.vet);
                                        }
                                      },
                                      onError: (String errorMsg) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(errorMsg,textAlign: TextAlign.center),
                                            backgroundColor: AppColors.lightRed,
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
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
                                    'Iniciar sesión',
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
                            context.go(AppRoutes.registro);
                          },
                          child: Text(
                            'Crear una nueva cuenta',
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
                  Positioned(
                    top: 0,
                    child: Image.asset(
                      "assets/LogoPawter.png",
                      width: 200,
                      height: 180,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}