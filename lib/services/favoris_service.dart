import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/produit.dart';

class FavorisService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _collection =>
      _firestore.collection('utilisateurs').doc(_uid).collection('favoris');

  // Ajoute ou retire un produit des favoris
  Future<void> toggleFavori(Produit produit) async {
    final doc = _collection.doc(produit.id);
    final snapshot = await doc.get();
    if (snapshot.exists) {
      await doc.delete();
    } else {
      await doc.set({
        'id': produit.id,
        'nom': produit.nom,
        'prix': produit.prix,
        'imageUrl': produit.imageUrl,
        'description': produit.description,
        'categorie': produit.categorie,
        'sousCategorie': produit.sousCategorie,
        'prixAuKg': produit.prixAuKg,
        'provenance': produit.provenance,
        'unite': produit.unite,
        'bio': produit.bio,
      });
    }
  }

  // Stream indiquant si un produit est en favori
  Stream<bool> estFavori(String produitId) {
    return _collection.doc(produitId).snapshots().map((s) => s.exists);
  }

  // Stream de tous les produits favoris
  Stream<List<Produit>> getFavoris() {
    return _collection.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Produit(
                    id: doc['id'],
                    nom: doc['nom'],
                    prix: (doc['prix'] as num).toDouble(),
                    imageUrl: doc['imageUrl'],
                    description: doc['description'] ?? '',
                    categorie: doc['categorie'] ?? 'autres',
                    sousCategorie: doc['sousCategorie'] ?? '',
                    prixAuKg: (doc['prixAuKg'] as num?)?.toDouble() ?? 0.0,
                    provenance: doc['provenance'] ?? 'France',
                    unite: doc['unite'] ?? 'kg',
                    bio: doc['bio'] ?? false,
                  ))
              .toList(),
        );
  }
}
