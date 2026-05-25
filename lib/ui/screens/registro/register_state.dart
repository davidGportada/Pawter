class RegisterState {
  final String nombre;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isLoading;

  // mensajes de error
  final String? nombreError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;

  RegisterState({
    this.nombre = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.nombreError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
  });

  RegisterState copyWith({
    String? nombre,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isLoading,

    String? nombreError,
    bool clearNombreError = false,

    String? emailError,
    bool clearEmailError = false,

    String? passwordError,
    bool clearPasswordError = false,

    String? confirmPasswordError,
    bool clearConfirmPasswordError = false,
  }) {
    return RegisterState(
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,

      nombreError: clearNombreError ? null : (nombreError ?? this.nombreError),
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError
          ? null
          : (passwordError ?? this.passwordError),
      confirmPasswordError: clearConfirmPasswordError
          ? null
          : (confirmPasswordError ?? this.confirmPasswordError),
    );
  }
}
