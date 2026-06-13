import { db } from "../src/db/store.js";

const demo = db.listBusinesses().find((b) => b.businessName === "Demo Marquee");
if (!demo) {
  console.log("Run npm run seed:demo first.");
  process.exit(1);
}

const existing = db.listSubscriptionPaymentsAdmin().find((p) => p.businessId === demo.id && p.status === "pending");
if (!existing) {
  db.createSubscriptionPayment({
    businessId: demo.id,
    planId: "standard",
    amount: 1799,
    paymentMethod: "bank_transfer",
    proofUrl: "https://example.com/proof/demo-payment.jpg",
    note: "Demo pending subscription payment for QA"
  });
  console.log("Created pending subscription payment for Demo Marquee.");
} else {
  console.log("Pending subscription payment already exists.");
}
