const { onCall, HttpsError } = require("firebase-functions/v2/https");
const stripeLib = require("stripe");
const admin = require("firebase-admin");

admin.initializeApp();

exports.creerPaymentIntent = onCall(
  { secrets: ["STRIPE_SECRET_KEY"] },
  async (request) => {
  const stripe = stripeLib(process.env.STRIPE_SECRET_KEY);
  const data = request.data;

  console.log("Data reçue:", JSON.stringify(data));

  let montant = Number(data.montant);
  console.log("Montant converti:", montant);

  if (!montant || montant <= 0 || isNaN(montant)) {
    console.error("Montant invalide:", montant);
    throw new HttpsError("invalid-argument", `Montant invalide: ${montant}`);
  }

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: montant,
      currency: "eur",
      automatic_payment_methods: { enabled: true },
    });

    return { clientSecret: paymentIntent.client_secret };

  } catch (error) {
    console.error("Erreur Stripe:", error.message);
    throw new HttpsError("internal", error.message);
  }
});
