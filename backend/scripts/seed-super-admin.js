import { db } from "../src/db/store.js";
import { hashPassword } from "../src/lib/password.js";
import { normalizePkPhone } from "../src/lib/phone.js";

const isProduction = process.env.NODE_ENV === "production";
const phone = normalizePkPhone(process.env.ADMIN_SEED_PHONE || "03009999999");
const password = process.env.ADMIN_SEED_PASSWORD;
const name = process.env.ADMIN_SEED_NAME || "Super Admin";
const role = process.env.ADMIN_SEED_ROLE || "super_admin";

if (isProduction && (!process.env.ADMIN_SEED_PHONE || !password)) {
  console.error(
    "In production, set ADMIN_SEED_PHONE and ADMIN_SEED_PASSWORD env vars to create the first Super Admin."
  );
  console.error("Example: ADMIN_SEED_PHONE=03XXXXXXXXX ADMIN_SEED_PASSWORD='strong-secret' npm run seed:admin");
  process.exit(1);
}

const seedPassword = password || "MarqueeFlowAdmin123";

if (db.findAdminByPhone(phone)) {
  console.log("Super Admin already exists.");
  if (!isProduction) {
    console.log(`Phone: ${process.env.ADMIN_SEED_PHONE || "03009999999"}`);
    console.log("Password: (existing — not shown)");
  }
  process.exit(0);
}

const passwordHash = await hashPassword(seedPassword);
db.createAdminUser({
  name,
  phone,
  passwordHash,
  role
});

console.log("Super Admin created.");
if (!isProduction) {
  console.log(`Phone: ${process.env.ADMIN_SEED_PHONE || "03009999999"}`);
  console.log(`Password: ${seedPassword}`);
  console.log(`Role: ${role}`);
} else {
  console.log(`Phone: ${process.env.ADMIN_SEED_PHONE}`);
  console.log("Password: (hidden — use ADMIN_SEED_PASSWORD value)");
  console.log(`Role: ${role}`);
}
