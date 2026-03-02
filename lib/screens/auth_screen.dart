import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();

  bool _estConnexion = true;
  bool _chargement = false;
  bool _afficherMotDePasse = false;
  String? _erreur;

  void _basculerMode() {
    setState(() {
      _estConnexion = !_estConnexion;
      _erreur = null;
    });
  }

  void _afficherResetMotDePasse() {
    final emailReset = TextEditingController(text: _emailController.text.trim());
    bool envoi = false;
    bool succes = false;
    String? erreurReset;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: ctx.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: ctx.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                "Mot de passe oublié ?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ctx.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Entrez votre email pour recevoir un lien de réinitialisation.",
                style: TextStyle(fontSize: 13, color: ctx.textHint),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailReset,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: Color(0xFF2563EB)),
                  filled: true,
                  fillColor: ctx.inputFill,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF2563EB), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (erreurReset != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFDC2626), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(erreurReset!,
                          style: const TextStyle(
                              color: Color(0xFFDC2626), fontSize: 13)),
                    ),
                  ]),
                ),
              if (succes)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Email envoyé ! Vérifiez votre boîte mail.",
                        style: TextStyle(
                            color: Color(0xFF16A34A), fontSize: 13),
                      ),
                    ),
                  ]),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: envoi || succes
                      ? null
                      : () async {
                          final email = emailReset.text.trim();
                          if (email.isEmpty) return;
                          setModalState(() {
                            envoi = true;
                            erreurReset = null;
                          });
                          try {
                            await _authService.reinitialiserMotDePasse(email);
                            setModalState(() {
                              envoi = false;
                              succes = true;
                            });
                          } catch (e) {
                            setModalState(() {
                              envoi = false;
                              erreurReset = e.toString();
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: envoi
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Envoyer le lien",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _soumettre() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      if (_estConnexion) {
        await _authService.connecter(
          email: _emailController.text.trim(),
          motDePasse: _motDePasseController.text.trim(),
        );
      } else {
        await _authService.inscrire(
          email: _emailController.text.trim(),
          motDePasse: _motDePasseController.text.trim(),
        );
      }
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _erreur = e.toString());
    } finally {
      setState(() => _chargement = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.shopping_bag_outlined,
                    size: 48, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                "Ma Boutique",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Des produits frais, chaque jour",
                style: TextStyle(fontSize: 14, color: context.textHint),
              ),
              const SizedBox(height: 36),

              // Carte formulaire
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _estConnexion ? "Connexion" : "Inscription",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _estConnexion
                          ? "Bienvenue ! Connectez-vous pour continuer."
                          : "Créez votre compte en quelques secondes.",
                      style: TextStyle(
                          fontSize: 13, color: context.textHint),
                    ),
                    const SizedBox(height: 24),

                    // Champ email
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "exemple@email.com",
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Color(0xFF2563EB)),
                        filled: true,
                        fillColor: context.inputFill,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF2563EB), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Champ mot de passe
                    TextField(
                      controller: _motDePasseController,
                      obscureText: !_afficherMotDePasse,
                      decoration: InputDecoration(
                        labelText: "Mot de passe",
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: Color(0xFF2563EB)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _afficherMotDePasse
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: context.textHint,
                          ),
                          onPressed: () => setState(() =>
                              _afficherMotDePasse = !_afficherMotDePasse),
                        ),
                        filled: true,
                        fillColor: context.inputFill,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF2563EB), width: 2),
                        ),
                      ),
                    ),
                    // Lien mot de passe oublié (connexion uniquement)
                    if (_estConnexion)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _afficherResetMotDePasse,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "Mot de passe oublié ?",
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Message d'erreur
                    if (_erreur != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFDC2626), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _erreur!,
                                style: const TextStyle(
                                    color: Color(0xFFDC2626), fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Bouton principal
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _chargement ? null : _soumettre,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _chargement
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                _estConnexion
                                    ? "Se connecter"
                                    : "S'inscrire",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Basculer mode
                    Center(
                      child: TextButton(
                        onPressed: _basculerMode,
                        child: Text(
                          _estConnexion
                              ? "Pas de compte ? S'inscrire"
                              : "Déjà un compte ? Se connecter",
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
