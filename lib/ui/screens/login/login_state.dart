class LoginState {
  final String email;
  final String password;
  final bool isLoading;
  //errores
  final String? emailError;
  final String? passwordError;
  /*
  Registro y login empecé haciendolo como si fuese kotlin pero luego me di cuenta que flutter es mucho más sencillo.
  De igual forma quise sentir esa transición y la he dejado solo para estas 2 clases como el navhost.
  */
  LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.emailError,
    this.passwordError,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? emailError,
    bool clearEmailError = false,
    String? passwordError,
    bool clearPasswordError = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError ? null : (passwordError ?? this.passwordError),
    );
  }
}