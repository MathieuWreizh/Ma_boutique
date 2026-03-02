import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/profil_service.dart';
import '../theme/app_colors.dart';

class ModifierCompteScreen extends StatefulWidget {
  const ModifierCompteScreen({super.key});

  @override
  State<ModifierCompteScreen> createState() => _ModifierCompteScreenState();
}

class _ModifierCompteScreenState extends State<ModifierCompteScreen> {
  final ProfilService _profilService = ProfilService();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();

  bool _chargement = true;
  bool _sauvegarde = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _chargerProfil();
  }

  Future<void> _chargerProfil() async {
    final profil = await _profilService.getProfil();
    if (profil != null) {
      _nomController.text = profil.nom;
      _prenomController.text = profil.prenom;
      _telephoneController.text = profil.telephone;
    }
    setState(() => _chargement = false);
  }

  Future<void> _sauvegarder() async {
    setState(() { _sauvegarde = true; _message = null; });
    final profil = UserProfile(
      uid: FirebaseAuth.instance.currentUser!.uid,
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      telephone: _telephoneController.text.trim(),
      adresse: '',
      ville: '',
      codePostal: '',
    );
    await _profilService.sauvegarderProfil(profil);
    setState(() { _sauvegarde = false; _message = "Profil mis à jour !"; });
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chargement) return Scaffold(body: Center(child: CircularProgressIndicator(color: context.textPrimary)));

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.cardBg,
        elevation: 0,
        title: Text("Gérer le compte",
            style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _champ(context, label: "Prénom", controller: _prenomController, icone: Icons.person),
            _champ(context, label: "Nom", controller: _nomController, icone: Icons.person_outline),
            _champ(context, label: "Téléphone", controller: _telephoneController,
                icone: Icons.phone, type: TextInputType.phone),
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle,
                      color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Text(_message!,
                      style:
                          const TextStyle(color: Color(0xFF16A34A))),
                ]),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sauvegarde ? null : _sauvegarder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _sauvegarde
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Sauvegarder",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _champ(BuildContext context, {required String label, required TextEditingController controller,
      required IconData icone, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icone, color: context.textSecondary),
          filled: true,
          fillColor: context.inputFill,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                BorderSide(color: context.textPrimary, width: 2),
          ),
        ),
      ),
    );
  }
}
