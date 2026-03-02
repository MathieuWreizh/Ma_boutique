import 'package:cloud_firestore/cloud_firestore.dart';
import 'produit.dart';
import 'adresse.dart';

class Commande {
  final String id;
  final List<Produit> produits;
  final double total;
  final DateTime date;
  final String statut; // "en cours", "expédiée", "livrée"
  final String modeLivraison; // "retrait" ou "livraison"
  final Adresse? adresseLivraison;

  Commande({
    required this.id,
    required this.produits,
    required this.total,
    required this.date,
    this.statut = 'en cours',
    this.modeLivraison = 'retrait',
    this.adresseLivraison,
  });

  // Firestore → Commande
  factory Commande.fromMap(String id, Map<String, dynamic> data) {
    final produitsData = data['produits'] as List<dynamic>;
    return Commande(
      id: id,
      produits: produitsData.map((p) => Produit(
        id: p['id'],
        nom: p['nom'],
        prix: (p['prix'] as num).toDouble(),
        imageUrl: p['imageUrl'] ?? '',
        description: p['description'] ?? '',
      )).toList(),
      total: (data['total'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      statut: data['statut'] ?? 'en cours',
      modeLivraison: data['modeLivraison'] ?? 'retrait',
      adresseLivraison: data['adresseLivraison'] != null
          ? Adresse.fromMap('', data['adresseLivraison'] as Map<String, dynamic>)
          : null,
    );
  }

  // Commande → Firestore
  Map<String, dynamic> toMap() {
    return {
      'produits': produits.map((p) => {
        'id': p.id,
        'nom': p.nom,
        'prix': p.prix,
        'imageUrl': p.imageUrl,
        'description': p.description,
      }).toList(),
      'total': total,
      'date': Timestamp.fromDate(date),
      'statut': statut,
      'modeLivraison': modeLivraison,
      'adresseLivraison': adresseLivraison?.toMap(),
    };
  }
}
