import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/produit.dart';

class ProduitService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('produits');

  // Récupérer tous les produits (en temps réel)
  Stream<List<Produit>> getProduits() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Produit.fromMap(doc.id, data);
      }).toList();
    });
  }

  // Ajouter un produit
  Future<void> ajouterProduit(Produit produit) async {
    await _collection.add(produit.toMap());
  }

  // Mettre à jour des champs spécifiques d'un produit
  Future<void> mettreAJourProduit(String id, Map<String, dynamic> data) async {
    await _collection.doc(id).update(data);
  }

  // Supprimer un produit
  Future<void> supprimerProduit(String id) async {
    await _collection.doc(id).delete();
  }
}
