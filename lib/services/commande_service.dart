import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/commande.dart';
import '../models/produit.dart';
import '../models/adresse.dart';

class CommandeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // Sauvegarder une nouvelle commande
  Future<void> passerCommande(
      List<Produit> produits, double total, String modeLivraison,
      [Adresse? adresseLivraison]) async {
    final commande = Commande(
      id: '',
      produits: produits,
      total: total,
      date: DateTime.now(),
      modeLivraison: modeLivraison,
      adresseLivraison: adresseLivraison,
    );


    await _firestore
        .collection('utilisateurs')
        .doc(_uid)
        .collection('commandes')  // 👈 sous-collection liée à l'utilisateur
        .add(commande.toMap());
  }
  // Mettre à jour le statut d'une commande
Future<void> mettreAJourStatut(String uid, String commandeId, String nouveauStatut) async {
  await _firestore
      .collection('utilisateurs')
      .doc(uid)
      .collection('commandes')
      .doc(commandeId)
      .update({'statut': nouveauStatut});
}

// Récupérer TOUTES les commandes de TOUS les utilisateurs (admin uniquement)
Stream<List<Map<String, dynamic>>> getToutesLesCommandes() {
  return _firestore
      .collectionGroup('commandes')
      // 👇 supprime la ligne orderBy qui causait le problème d'index
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            return {
              'uid': doc.reference.parent.parent!.id,
              'commande': Commande.fromMap(doc.id, doc.data()),
            };
          }).toList());
}

  // Récupérer toutes les commandes de l'utilisateur
  Stream<List<Commande>> getCommandes() {
    return _firestore
        .collection('utilisateurs')
        .doc(_uid)
        .collection('commandes')
        .orderBy('date', descending: true) // 👈 plus récent en premier
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Commande.fromMap(doc.id, doc.data()))
            .toList());
  }
}
