import 'package:cloud_firestore/cloud_firestore.dart';

class CodePromo {
  final String id;
  final String code;
  final String type; // "pourcentage" ou "fixe"
  final double valeur;
  final String description;
  final double minAchat;
  final bool actif;
  final DateTime? dateExpiration; // null = pas d'expiration
  final int? maxUtilisations;    // null = illimité
  final int utilisationsCount;   // nombre de fois utilisé

  CodePromo({
    required this.id,
    required this.code,
    required this.type,
    required this.valeur,
    required this.description,
    this.minAchat = 0.0,
    this.actif = true,
    this.dateExpiration,
    this.maxUtilisations,
    this.utilisationsCount = 0,
  });

  factory CodePromo.fromMap(String id, Map<String, dynamic> data) {
    return CodePromo(
      id: id,
      code: data['code'] ?? '',
      type: data['type'] ?? 'pourcentage',
      valeur: (data['valeur'] as num).toDouble(),
      description: data['description'] ?? '',
      minAchat: (data['minAchat'] as num?)?.toDouble() ?? 0.0,
      actif: data['actif'] ?? true,
      dateExpiration: data['dateExpiration'] != null
          ? (data['dateExpiration'] as Timestamp).toDate()
          : null,
      maxUtilisations: data['maxUtilisations'] as int?,
      utilisationsCount: (data['utilisationsCount'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'type': type,
      'valeur': valeur,
      'description': description,
      'minAchat': minAchat,
      'actif': actif,
      'dateExpiration':
          dateExpiration != null ? Timestamp.fromDate(dateExpiration!) : null,
      'maxUtilisations': maxUtilisations,
      'utilisationsCount': utilisationsCount,
    };
  }

  Map<String, dynamic> toInventaireMap() {
    return {
      'code': code,
      'type': type,
      'valeur': valeur,
      'description': description,
      'minAchat': minAchat,
      'dateExpiration':
          dateExpiration != null ? Timestamp.fromDate(dateExpiration!) : null,
      'dateAjout': Timestamp.now(),
    };
  }

  bool get estExpire =>
      dateExpiration != null && DateTime.now().isAfter(dateExpiration!);

  bool get estEpuise =>
      maxUtilisations != null && utilisationsCount >= maxUtilisations!;

  String get libelle {
    if (type == 'pourcentage') return '-${valeur.toStringAsFixed(0)}%';
    return '-${valeur.toStringAsFixed(2)} €';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CodePromo && other.code == code);

  @override
  int get hashCode => code.hashCode;
}
