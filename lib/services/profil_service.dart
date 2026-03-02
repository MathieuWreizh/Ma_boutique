import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../models/adresse.dart';

class ProfilService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // Lire le profil
  Future<UserProfile?> getProfil() async {
    final doc = await _firestore.collection('utilisateurs').doc(_uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(_uid, doc.data()!);
  }

  // Sauvegarder le profil
  Future<void> sauvegarderProfil(UserProfile profil) async {
    await _firestore
        .collection('utilisateurs')
        .doc(_uid)
        .set(profil.toMap(), SetOptions(merge: true));
  }

  // Récupérer les adresses
  Stream<List<Adresse>> getAdresses() {
    return _firestore
        .collection('utilisateurs')
        .doc(_uid)
        .collection('adresses')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Adresse.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Ajouter une adresse
  Future<void> ajouterAdresse(Adresse adresse) async {
    await _firestore
        .collection('utilisateurs')
        .doc(_uid)
        .collection('adresses')
        .add(adresse.toMap());
  }

  // Supprimer une adresse
  Future<void> supprimerAdresse(String id) async {
    await _firestore
        .collection('utilisateurs')
        .doc(_uid)
        .collection('adresses')
        .doc(id)
        .delete();
  }
}