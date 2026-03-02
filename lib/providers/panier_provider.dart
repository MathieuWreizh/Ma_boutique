import 'package:flutter/material.dart';
import '../models/produit.dart';
import '../models/code_promo.dart';

class PanierProvider extends ChangeNotifier {
  final List<Produit> _articles = [];
  CodePromo? _codePromoApplique;

  List<Produit> get articles => _articles;
  int get nombreArticles => _articles.length;
  CodePromo? get codePromoApplique => _codePromoApplique;

  double get total => _articles.fold(0, (sum, p) => sum + p.prix);

  double get totalApresRemise {
    if (_codePromoApplique == null) return total;
    if (_codePromoApplique!.type == 'pourcentage') {
      return total * (1 - _codePromoApplique!.valeur / 100);
    }
    final remise = total - _codePromoApplique!.valeur;
    return remise < 0 ? 0 : remise;
  }

  void ajouterProduit(Produit produit) {
    _articles.add(produit);
    notifyListeners();
  }

  void supprimerProduit(Produit produit) {
    _articles.remove(produit);
    notifyListeners();
  }

  void viderPanier() {
    _articles.clear();
    _codePromoApplique = null;
    notifyListeners();
  }

  void appliquerCodePromo(CodePromo code) {
    _codePromoApplique = code;
    notifyListeners();
  }

  void retirerCodePromo() {
    _codePromoApplique = null;
    notifyListeners();
  }
}
