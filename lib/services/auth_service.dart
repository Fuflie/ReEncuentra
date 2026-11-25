import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  Future<User?> currentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<UserCredential> iniciarSesionGoogle() async {
    final GoogleSignInAccount cuenta = await GoogleSignIn.instance
        .authenticate();

    final GoogleSignInAuthentication autenticacion = cuenta.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: autenticacion.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.signOut();
  }
}
