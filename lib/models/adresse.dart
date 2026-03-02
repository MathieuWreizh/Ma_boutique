class Adresse {
  final String id;
  final String label; // "Maison", "Travail", "Autres"
  final String adresse;
  final String ville;
  final String codePostal;

  Adresse({
    required this.id,
    required this.label,
    required this.adresse,
    required this.ville,
    required this.codePostal,
  });

  factory Adresse.fromMap(String id, Map<String, dynamic> data) {
    return Adresse(
      id: id,
      label: data['label'] ?? '',
      adresse: data['adresse'] ?? '',
      ville: data['ville'] ?? '',
      codePostal: data['codePostal'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'adresse': adresse,
      'ville': ville,
      'codePostal': codePostal,
    };
  }
}