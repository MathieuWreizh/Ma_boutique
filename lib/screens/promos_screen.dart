import 'package:flutter/material.dart';
import '../models/code_promo.dart';
import '../services/promo_service.dart';
import '../theme/app_colors.dart';

class PromosScreen extends StatefulWidget {
  const PromosScreen({super.key});

  @override
  State<PromosScreen> createState() => _PromosScreenState();
}

class _PromosScreenState extends State<PromosScreen> {
  final _controller = TextEditingController();
  final _promoService = PromoService();
  bool _chargement = false;

  Future<void> _ajouterCode() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;

    setState(() => _chargement = true);
    try {
      await _promoService.validerEtAjouter(code);
      _controller.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: const [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Expanded(child: Text('Code promo ajouté à votre inventaire !')),
            ]),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                      e.toString().replaceFirst('Exception: ', ''))),
            ]),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mes codes promos',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Section saisie
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            color: context.cardBg,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Entrez un code promo',
                      hintStyle:
                          TextStyle(color: context.textHint),
                      prefixIcon: Icon(Icons.local_offer_outlined,
                          color: context.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: context.textPrimary, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: context.inputFill,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _chargement ? null : _ajouterCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _chargement
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Ajouter',
                            style:
                                TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: context.borderColor),

          // Liste des codes
          Expanded(
            child: StreamBuilder<List<CodePromo>>(
              stream: _promoService.getMesCodes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child:
                        CircularProgressIndicator(color: context.textPrimary),
                  );
                }

                final codes = snapshot.data ?? [];

                if (codes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: context.containerBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.local_offer_outlined,
                              size: 46,
                              color: context.textHint,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Aucun code promo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ajoutez un code ci-dessus pour\nle retrouver ici.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.textHint,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: codes.length,
                  separatorBuilder: (_, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final code = codes[index];
                    return _CodePromoCard(code: code);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CodePromoCard extends StatelessWidget {
  final CodePromo code;

  const _CodePromoCard({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.containerBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_offer_outlined,
              color: context.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code.code,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: context.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
                if (code.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    code.description,
                    style: TextStyle(
                        color: context.textSecondary, fontSize: 13),
                  ),
                ],
                if (code.dateExpiration != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Expire le ${code.dateExpiration!.day.toString().padLeft(2, '0')}/'
                    '${code.dateExpiration!.month.toString().padLeft(2, '0')}/'
                    '${code.dateExpiration!.year}',
                    style: TextStyle(
                      color: code.estExpire
                          ? const Color(0xFFDC2626)
                          : const Color(0xFFD97706),
                      fontSize: 12,
                    ),
                  ),
                ],
                if (code.minAchat > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Minimum d\'achat : ${code.minAchat.toStringAsFixed(2)} €',
                    style: TextStyle(
                        color: context.textHint, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              code.libelle,
              style: const TextStyle(
                color: Color(0xFF16A34A),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
