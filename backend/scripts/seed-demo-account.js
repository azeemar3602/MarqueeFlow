import { db } from "../src/db/store.js";
import { hashPassword } from "../src/lib/password.js";
import { normalizePkPhone } from "../src/lib/phone.js";

const DEMO = {
  name: "Demo Owner",
  phone: "03001234567",
  password: "MarqueeFlow123",
  businessName: "Demo Marquee",
  address: "Karachi, Pakistan"
};

const phone = normalizePkPhone(DEMO.phone);

if (db.findUserByPhone(phone)) {
  console.log("Demo account already exists.");
  console.log(`Phone: ${DEMO.phone}`);
  console.log(`Password: ${DEMO.password}`);
  process.exit(0);
}

const passwordHash = await hashPassword(DEMO.password);
const { user, business } = db.createOwner({
  name: DEMO.name,
  phone,
  passwordHash,
  businessName: DEMO.businessName,
  address: DEMO.address
});
db.seedPackagesIfEmpty(business.id);
db.startTrial(business.id, "basic");
db.updateMarqueeApproval(business.id, "approved", null);

console.log("Demo account created.");
console.log(`Phone: ${DEMO.phone}`);
console.log(`Password: ${DEMO.password}`);
console.log(`Role: ${user.role}`);
console.log(`Business: ${business.businessName}`);
