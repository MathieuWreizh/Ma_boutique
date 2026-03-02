import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupérer l'utilisateur connecté
  User? get utilisateurActuel => _auth.currentUser;

  // Écouter les changements de connexion en temps réel
  Stream<User?> get etatConnexion => _auth.authStateChanges();

  // Inscription
  Future<UserCredential?> inscrire({
    required String email,
    required String motDePasse,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: motDePasse,
      );
    } on FirebaseAuthException catch (e) {
      throw _getMessage(e.code);
    }
  }

  // Connexion
  Future<UserCredential?> connecter({
    required String email,
    required String motDePasse,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: motDePasse,
      );
    } on FirebaseAuthException catch (e) {
      throw _getMessage(e.code);
    }
  }

  // Déconnexion
  Future<void> deconnecter() async {
    await _auth.signOut();
  }

  // Réinitialiser le mot de passe
  Future<void> reinitialiserMotDePasse(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getMessage(e.code);
    }
  }

  // Convertir les codes d'erreur Firebase en messages lisibles
  String _getMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'weak-password':
        return 'Le mot de passe doit faire au moins 6 caractères.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      default:
        return 'Une erreur est survenue. Réessaie.';
    }
  }
}