const admin = require("firebase-admin");
const serviceAccount = require("../../firebase-service-account.json");

// Handle private key if it's a string
if (typeof serviceAccount.private_key === "string") {
  serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, "\n");
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;
