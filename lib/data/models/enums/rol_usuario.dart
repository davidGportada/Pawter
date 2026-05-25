enum RolUsuario {
veterinario,
cliente;

  static RolUsuario? tryParse(String cad){
    switch (cad.toLowerCase()){
      case 'veterinario':
        return RolUsuario.veterinario;
      case 'cliente':
        return RolUsuario.cliente;
      default:
        return null;
    }
  } 
   @override
  String toString() {
    return name;
  }
}