class Produit {
  final String id;
  final String nom;
  final double prix;
  final String imageUrl;
  final String description;
  final String categorie;
  final String sousCategorie;
  final double prixAuKg;      
  final String provenance;    
  final String unite;         // 👈 "kg", "pièce"
  final bool bio;
  final bool phare;           // 👈 apparaît dans "Produits phares ⭐"
  final bool saison;          // 👈 apparaît dans "Légumes de saison 🌱"

  Produit({
    required this.id,
    required this.nom,
    required this.prix,
    required this.imageUrl,
    required this.description,
    this.categorie = 'autres',
    this.sousCategorie = '',
    this.prixAuKg = 0.0,
    this.provenance = 'France',
    this.unite = 'kg',
    this.bio = false,
    this.phare = false,
    this.saison = false,
  });

  factory Produit.fromMap(String id, Map<String, dynamic> data) {
    return Produit(
      id: id,
      nom: data['nom'] ?? '',
      prix: (data['prix'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      categorie: data['categorie'] ?? 'autres',
      sousCategorie: data['sousCategorie'] ?? '',
      prixAuKg: (data['prixAuKg'] ?? 0).toDouble(),
      provenance: data['provenance'] ?? 'France',
      unite: data['unite'] ?? 'kg',
      bio: data['bio'] ?? false,
      phare: data['phare'] ?? false,
      saison: data['saison'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prix': prix,
      'imageUrl': imageUrl,
      'description': description,
      'categorie': categorie,
      'sousCategorie': sousCategorie,
      'prixAuKg': prixAuKg,
      'provenance': provenance,
      'unite': unite,
      'bio': bio,
      'phare': phare,
      'saison': saison,
    };
  }
}