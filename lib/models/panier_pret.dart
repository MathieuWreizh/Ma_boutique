class PanierPret {
  final String id;
  final String nom;
  final String emoji;
  final String contenu;  // texte libre décrivant le contenu
  final double prix;
  final String theme;            // 'vert' | 'orange' | 'bleu' | 'rouge'
  final int ordre;               // pour trier les paniers dans l'affichage
  final List<String> produitIds; // IDs Firestore des produits inclus

  PanierPret({
    required this.id,
    required this.nom,
    required this.emoji,
    required this.contenu,
    required this.prix,
    this.theme = 'vert',
    this.ordre = 0,
    this.produitIds = const [],
  });

  factory PanierPret.fromMap(String id, Map<String, dynamic> data) {
    return PanierPret(
      id: id,
      nom: data['nom'] ?? '',
      emoji: data['emoji'] ?? '🧺',
      contenu: data['contenu'] ?? '',
      prix: (data['prix'] ?? 0).toDouble(),
      theme: data['theme'] ?? 'vert',
      ordre: data['ordre'] ?? 0,
      produitIds: List<String>.from(data['produitIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'emoji': emoji,
      'contenu': contenu,
      'prix': prix,
      'theme': theme,
      'ordre': ordre,
      'produitIds': produitIds,
    };
  }
}
