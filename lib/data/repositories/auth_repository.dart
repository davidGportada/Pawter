import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pawter/data/models/usuarios.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://pawter-dgm96-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref();

  Future<User?> emailRegistro(
    String email,
    String password,
    Usuario usuario,
  ) async {
    try {
      UserCredential resultado = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (resultado.user != null) {
        await _dbRef
            .child('usuarios')
            .child(resultado.user!.uid)
            .set(usuario.copyWith(id: resultado.user!.uid).toJson());
      }
      return resultado.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Usuario>> getTodosLosUsuarios() async {
    try {
      final buscarEnDB = await _dbRef.child('usuarios').get();
      List<Usuario> lista = [];
      if (buscarEnDB.exists) {
        final map = Map<String, dynamic>.from(buscarEnDB.value as Map);
        map.forEach((key, value) {
          final userMap = Map<String, dynamic>.from(value as Map);
          lista.add(Usuario.fromJson(userMap));
        });
      }
      return lista;
    } catch (e) {
      rethrow;
    }
  }

  //Uso un stream reactivo, para que el veterinario vea todos los cambios en la pestaña pacientes
  Stream<List<Usuario>> getTodosLosUsuariosStream() {
    return _dbRef.child('usuarios').onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final map = Map<String, dynamic>.from(event.snapshot.value as Map);
      return map.entries.map((e) {
        return Usuario.fromJson(Map<String, dynamic>.from(e.value as Map));
      }).toList();
    });
  }
  //metodo que actualiza los datos del cliente, necesitando el dni el telefono y la dirección para completar la ficha por completo
  Future<void> actualizarDatosCliente(
    String uid,
    String dni,
    String telefono,
    String direccion,
  ) async {
    try {
      await _dbRef.child("usuarios").child(uid).update({
        "dni": dni,
        "telefono": telefono,
        "direccion": direccion,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> logearConEmail(String email, String password) async {
    try {
      UserCredential resultado = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return resultado.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deslogear() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<Usuario?> getDatosDelUsuario(String uid) async {
    final datosUsuario = await _dbRef.child('usuarios').child(uid).get();
    if (datosUsuario.exists) {
      return Usuario.fromJson(
        Map<String, dynamic>.from(datosUsuario.value as Map),
      );
    }
    return null;
  }

  //Metodo reactivo que permite al cliente reconocer que sus datos han cambiado y así mostrarse nuevamente en la interfaz.
  Stream<Usuario?> flujoGetDatosUsu(String uid) {
    return _dbRef.child('usuarios').child(uid).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return null;
      return Usuario.fromJson(
        Map<String, dynamic>.from(event.snapshot.value as Map),
      );
    });
  }

  Future<void> enviarEmailVerificacion() async {
    try {
      User? unUsuario = _auth.currentUser;
      await unUsuario?.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> envioResetearPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}
