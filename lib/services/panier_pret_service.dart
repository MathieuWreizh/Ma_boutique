import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/panier_pret.dart';

class PanierPretService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('paniers_prets');

  // Récupérer tous les paniers triés par ordre
  Stream<List<PanierPret>> getPaniersPrets() {
    return _collection.orderBy('ordre').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PanierPret.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Ajouter un panier
  Future<void> ajouterPanier(PanierPret panier) async {
    await _collection.add(panier.toMap());
  }

  // Mettre à jour des champs
  Future<void> mettreAJour(String id, Map<String, dynamic> data) async {
    await _collection.doc(id).update(data);
  }

  // Supprimer un panier
  Future<void> supprimerPanier(String id) async {
    await _collection.doc(id).delete();
  }
}
