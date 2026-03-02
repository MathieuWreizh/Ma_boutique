class UserProfile {
  final String uid;
  final String nom;
  final String prenom;
  final String telephone;
  final String adresse;
  final String ville;
  final String codePostal;
  final String pays;

  UserProfile({
    required this.uid,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.adresse,
    required this.ville,
    required this.codePostal,
    this.pays = 'France',
  });

  // Convertir depuis Firestore → UserProfile
  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      telephone: data['telephone'] ?? '',
      adresse: data['adresse'] ?? '',
      ville: data['ville'] ?? '',
      codePostal: data['codePostal'] ?? '',
      pays: data['pays'] ?? 'France',
    );
  }

  // Convertir UserProfile → Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'adresse': adresse,
      'ville': ville,
      'codePostal': codePostal,
      'pays': pays,
    };
  }
}