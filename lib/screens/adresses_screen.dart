import 'package:flutter/material.dart';
import '../models/adresse.dart';
import '../services/profil_service.dart';
import '../theme/app_colors.dart';

class AdressesScreen extends StatelessWidget {
  const AdressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ProfilService();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.cardBg,
        elevation: 0,
        title: Text("Mes adresses",
            style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E293B),
        onPressed: () => _afficherFormulaire(context, service),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Adresse>>(
        stream: service.getAdresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: context.textPrimary),
            );
          }
          final adresses = snapshot.data ?? [];
          if (adresses.isEmpty) {
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
                      child: Icon(Icons.location_off_outlined,
                          size: 46, color: context.textHint),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Aucune adresse",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ajoutez une adresse via le bouton +",
                    style: TextStyle(color: context.textHint, fontSize: 14),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: adresses.length,
            itemBuilder: (context, index) {
              final adresse = adresses[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                        adresse.label == 'Maison'
                            ? Icons.home_outlined
                            : adresse.label == 'Travail'
                                ? Icons.work_outline
                                : Icons.location_on_outlined,
                        color: context.textPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(adresse.label,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary)),
                          Text(
                            "${adresse.adresse}, ${adresse.codePostal} ${adresse.ville}",
                            style: TextStyle(
                                color: context.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => service.supprimerAdresse(adresse.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _afficherFormulaire(BuildContext context, ProfilService service) {
    final adresseController = TextEditingController();
    final villeController = TextEditingController();
    final cpController = TextEditingController();
    String labelSelectionne = 'Maison';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                "Ajouter une adresse",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Choisissez un type et renseignez votre adresse.",
                style: TextStyle(fontSize: 13, color: context.textHint),
              ),
              const SizedBox(height: 16),
              // Sélecteur de label
              Row(
                children: ['Maison', 'Travail', 'Autre'].map((label) {
                  final selectionne = labelSelectionne == label;
                  return GestureDetector(
                    onTap: () => setModalState(() => labelSelectionne = label),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selectionne
                            ? const Color(0xFF1E293B)
                            : context.containerBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(label,
                          style: TextStyle(
                              color: selectionne ? Colors.white : context.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adresseController,
                decoration: InputDecoration(
                  labelText: "Adresse",
                  prefixIcon: Icon(Icons.home_outlined,
                      color: context.textSecondary),
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
                    borderSide: BorderSide(
                        color: context.textPrimary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Code postal",
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
                          borderSide: BorderSide(
                              color: context.textPrimary, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: villeController,
                      decoration: InputDecoration(
                        labelText: "Ville",
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
                          borderSide: BorderSide(
                              color: context.textPrimary, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await service.ajouterAdresse(Adresse(
                      id: '',
                      label: labelSelectionne,
                      adresse: adresseController.text.trim(),
                      ville: villeController.text.trim(),
                      codePostal: cpController.text.trim(),
                    ));
                    if (context.mounted) Navigator.pop(context);
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
                  child: const Text(
                    "Ajouter l'adresse",
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
}
