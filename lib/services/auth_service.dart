import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Retorna o usuário atualmente autenticado.
  User? get currentUser => _auth.currentUser;

  // Observa alterações no estado de autenticação.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Cadastra um novo usuário.
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(name.trim());

    return credential;
  }

  // Realiza o login.
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Encerra a sessão.
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Envia e-mail para redefinição de senha.
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
