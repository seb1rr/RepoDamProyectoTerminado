import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Instancia de FirebaseAuth (única para toda la app)
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instancia de GoogleSignIn para manejar el login con Google
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Método para iniciar sesión con Google
  Future<User?> signInWithGoogle() async {
    // Abre la ventana de selección de cuenta Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    // Si el usuario cancela el login, se devuelve null
    if (googleUser == null) return null;
    // Obtiene los datos de autenticación de Google (tokens)
    final googleAuth = await googleUser.authentication;
    // Crea las credenciales para Firebase usando los tokens de Google
    final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    // Inicia sesión en Firebase con las credenciales de Google
    final userCred = await _auth.signInWithCredential(credential);
    // Devuelve el usuario autenticado
    return userCred.user;
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
