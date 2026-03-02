import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/code_promo.dart';

class PromoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // Valide un code et l'ajoute à l'inventaire de l'utilisateur
  Future<CodePromo> validerEtAjouter(String code) async {
    final codeUpper = code.trim().toUpperCase();

    // Cherche le code dans la collection globale
    final query = await _firestore
        .collection('codes_promos')
        .where('code', isEqualTo: codeUpper)
        .where('actif', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Code promo invalide ou inactif.');
    }

    final doc = query.docs.first;
    final codePromo = CodePromo.fromMap(doc.id, doc.data());

    // Vérifie l'expiration
    if (codePromo.estExpire) {
      throw Exception('Ce code promo a expiré.');
    }

    // Vérifie la limite d'utilisations
    if (codePromo.estEpuise) {
      throw Exception('Ce code promo a atteint sa limite d\'utilisations.');
    }

    // Vérifie si l'utilisateur a déjà ce code dans son inventaire
    final inventaire = await _firestore
        .collection('utilisateurs')
        .doc(_uid)
        .collection('codes_promos')
        .where('code', isEqualTo: codeUpper)
        .limit(1)
        .get();

    if (inventaire.docs.isNotEmpty) {
      throw Exception('Ce code est déjà dans votre inventaire.');
    }

    // Incrémente le compteur d'utilisations et ajoute à l'inventaire
    await Future.wait([
      _firestore.collection('codes_promos').doc(doc.id).update({
        'utilisationsCount': FieldValue.increment(1),
      }),
      _firestore
          .collection('utilisateurs')
          .doc(_uid)
          .collection('codes_promos')
          .add(codePromo.toInventaireMap()),
    ]);

    return codePromo;
  }

  // Récupère l'inventaire de codes promos de l'utilisateur
  Stream<List<CodePromo>> getMesCodes() {
    return _firestore
        .collection('utilisateurs')
        .doc(_uid)
        .collection('codes_promos')
        .orderBy('dateAjout', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CodePromo.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Admin : crée un nouveau code promo global
  Future<void> creerCode(CodePromo codePromo) async {
    await _firestore.collection('codes_promos').add(codePromo.toMap());
  }
}
