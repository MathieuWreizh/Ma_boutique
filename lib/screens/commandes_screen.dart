import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/commande.dart';
import '../models/produit.dart';
import '../services/commande_service.dart';
import '../theme/app_colors.dart';

class CommandesScreen extends StatelessWidget {
  const CommandesScreen({super.key});

  // Couleur selon statut
  Color _couleur(String statut) {
    switch (statut) {
      case 'expédiée': return const Color(0xFF2563EB);
      case 'livrée':   return const Color(0xFF16A34A);
      default:         return const Color(0xFFD97706); // en cours
    }
  }

  // Icône selon statut
  IconData _icone(String statut) {
    switch (statut) {
      case 'expédiée': return Icons.local_shipping_outlined;
      case 'livrée':   return Icons.check_circle_outline;
      default:         return Icons.access_time_rounded;
    }
  }

  // Emoji selon statut
  String _emoji(String statut) {
    switch (statut) {
      case 'expédiée': return '🚚';
      case 'livrée':   return '✅';
      default:         return '🟠';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.cardBg,
        elevation: 0,
        title: Text(
          "Mes commandes",
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: context.textPrimary),
      ),
      body: StreamBuilder<List<Commande>>(
        stream: CommandeService().getCommandes(),
        builder: (context, snapshot) {

          // ── Chargement ────────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: context.textPrimary),
            );
          }

          // ── Erreur ────────────────────────────────────────────────────
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_outlined,
                      size: 48, color: context.textHint),
                  const SizedBox(height: 12),
                  Text(
                    "Erreur : ${snapshot.error}",
                    style: TextStyle(color: context.textHint),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final commandes = snapshot.data ?? [];

          // ── État vide ─────────────────────────────────────────────────
          if (commandes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: context.containerBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.receipt_long_outlined,
                        size: 46, color: context.textHint),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Aucune commande",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Vos commandes apparaîtront ici",
                    style: TextStyle(color: context.textHint, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          // ── Liste des commandes ───────────────────────────────────────
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: commandes.length,
            itemBuilder: (context, index) {
              final commande = commandes[index];
              return _CommandeCard(
                commande: commande,
                couleur: _couleur(commande.statut),
                icone: _icone(commande.statut),
                emoji: _emoji(commande.statut),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Carte commande ────────────────────────────────────────────────────────────

class _CommandeCard extends StatefulWidget {
  final Commande commande;
  final Color couleur;
  final IconData icone;
  final String emoji;

  const _CommandeCard({
    required this.commande,
    required this.couleur,
    required this.icone,
    required this.emoji,
  });

  @override
  State<_CommandeCard> createState() => _CommandeCardState();
}

class _CommandeCardState extends State<_CommandeCard> {
  bool _ouvert = false;

  @override
  Widget build(BuildContext context) {
    final commande = widget.commande;
    final dateFormatee =
        DateFormat('dd MMM yyyy  •  HH:mm', 'fr_FR').format(commande.date);
    final nbArticles = commande.produits.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [

          // ── En-tête ─────────────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _ouvert = !_ouvert),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icône statut
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: widget.couleur.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.icone,
                            color: widget.couleur, size: 20),
                      ),
                      const SizedBox(width: 12),

                      // Date + nb articles
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateFormatee,
                              style: TextStyle(
                                fontSize: 13,
                                color: context.textHint,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "$nbArticles article${nbArticles > 1 ? 's' : ''}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Total + chevron
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${commande.total.toStringAsFixed(2)} €",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Icon(
                            _ouvert
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: context.textHint,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Badge statut + barre de progression
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: widget.couleur.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: widget.couleur.withValues(alpha: 0.30)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.emoji,
                                style: const TextStyle(fontSize: 11)),
                            const SizedBox(width: 5),
                            Text(
                              commande.statut[0].toUpperCase() +
                                  commande.statut.substring(1),
                              style: TextStyle(
                                color: widget.couleur,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _BarreProgression(commande.statut)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Détail produits (dépliable) ──────────────────────────────
          if (_ouvert) ...[
            Container(
              height: 1,
              color: context.borderColor,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Articles",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.textHint,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...() {
                    final grouped = <String, ({Produit produit, int quantite})>{};
                    for (final p in commande.produits) {
                      if (grouped.containsKey(p.id)) {
                        grouped[p.id] = (produit: p, quantite: grouped[p.id]!.quantite + 1);
                      } else {
                        grouped[p.id] = (produit: p, quantite: 1);
                      }
                    }
                    return grouped.values.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                item.produit.imageUrl,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 52,
                                  height: 52,
                                  color: context.containerBg,
                                  child: Icon(Icons.image_not_supported,
                                      color: context.chevronColor, size: 22),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Nom + quantité
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.produit.nom,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: context.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.quantite > 1)
                                    Text(
                                      'x${item.quantite}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.textHint,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Prix total
                            Text(
                              "${(item.produit.prix * item.quantite).toStringAsFixed(2)} €",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }(),

                  // Séparateur + total
                  Container(
                    height: 1,
                    color: context.dividerColor,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                        ),
                      ),
                      Text(
                        "${commande.total.toStringAsFixed(2)} €",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        commande.modeLivraison == 'livraison'
                            ? Icons.local_shipping_outlined
                            : Icons.store_outlined,
                        size: 14,
                        color: context.textHint,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        commande.modeLivraison == 'livraison'
                            ? 'Livraison à domicile'
                            : 'Retrait en magasin',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (commande.modeLivraison == 'livraison' &&
                      commande.adresseLivraison != null) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        "${commande.adresseLivraison!.adresse}, "
                        "${commande.adresseLivraison!.codePostal} "
                        "${commande.adresseLivraison!.ville}",
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textHint,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Barre de progression statut ──────────────────────────────────────────────

class _BarreProgression extends StatelessWidget {
  final String statut;

  const _BarreProgression(this.statut);

  int get _etape {
    switch (statut) {
      case 'expédiée': return 1;
      case 'livrée':   return 2;
      default:         return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final actif = i <= _etape;
        final estDernier = i == 2;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: actif
                        ? context.textPrimary
                        : context.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (!estDernier) const SizedBox(width: 2),
            ],
          ),
        );
      }),
    );
  }
}
