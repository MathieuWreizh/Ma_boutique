import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';

class StripeService {
  static void init() {
    // 👇 Clé PUBLIQUE uniquement (pk_test_ ou pk_live_)
    Stripe.publishableKey = 'pk_test_51Oc89YEeMOw8l3rt4ANt0jt8pZKUMvgqxcTdNx6FlBaDBxD0JxNKzikyQYW2AUQhsPTsKJLdynTnk8qWZkASpBxg005sVYhwdT';
  }

  Future<bool> payerCommande(double montantEuros) async {
    try {
      final montantCentimes = (montantEuros * 100).round();

      final fonctions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final callable = fonctions.httpsCallable('creerPaymentIntent');
      final resultat = await callable.call(<String, dynamic>{'montant': montantCentimes});

      final clientSecret = resultat.data['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Fruits & Légumes',
          style: ThemeMode.light,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFF1E293B),
              background: const Color(0xFFF8FAFC),
              componentBackground: Colors.white,
              componentBorder: const Color(0xFFE2E8F0),
              componentDivider: const Color(0xFFE2E8F0),
              primaryText: const Color(0xFF1E293B),
              secondaryText: const Color(0xFF64748B),
              componentText: const Color(0xFF1E293B),
              placeholderText: const Color(0xFF94A3B8),
              icon: const Color(0xFF64748B),
            ),
            shapes: PaymentSheetShape(
              borderRadius: 12,
              borderWidth: 1.0,
              shadow: PaymentSheetShadowParams(
                color: Colors.black,
                opacity: 0.04,
                offset: PaymentSheetShadowOffset(x: 0, y: 2),
              ),
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              shapes: PaymentSheetPrimaryButtonShape(
                blurRadius: 0,
              ),
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: const Color(0xFF1E293B),
                  text: Colors.white,
                  border: Colors.transparent,
                ),
              ),
            ),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return true;

    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return false;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}