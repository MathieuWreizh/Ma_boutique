import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/produit.dart';
import '../services/produit_service.dart';
import '../widgets/produit_card.dart';
import '../theme/app_colors.dart';

class SousCategorieScreen extends StatelessWidget {
  final String categorie; // "fruits", "légumes", "autres"

  const SousCategorieScreen({super.key, required this.categorie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          categorie[0].toUpperCase() + categorie.substring(1),
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: context.textSecondary),
            onPressed: () => context.push('/recherche'),
          ),
        ],
      ),
      body: StreamBuilder<List<Produit>>(
        stream: ProduitService().getProduits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)));
          }

          final tousLesProduits = snapshot.data ?? [];

          final produits = tousLesProduits
              .where((p) => p.categorie == categorie)
              .toList();

          if (produits.isEmpty) {
            return Center(
              child: Text("Aucun produit dans cette catégorie",
                  style: TextStyle(color: context.textHint)),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: produits.length,
            itemBuilder: (context, index) {
              final produit = produits[index];
              return ProduitCard(
                produit: produit,
                onTap: () => context.push(
                  '/produit/${produit.id}',
                  extra: produit,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
