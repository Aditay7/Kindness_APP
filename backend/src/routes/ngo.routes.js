const express = require("express");
const router = express.Router();
const {
  auth,
  checkRole,
  authenticateToken,
} = require("../middleware/auth.middleware");
const {
  getDashboard,
  claimDonation,
  updateClaimStatus,
  updateProfile,
  getProfile,
  getAvailableDonations,
  getClaimedDonations,
} = require("../controllers/ngo.controller");
const NGO = require("../models/ngo.model");

// All routes require authentication and NGO role
router.use(auth, checkRole("ngo"));

// Dashboard
router.get("/dashboard", getDashboard);

// Profile
router.get("/profile", getProfile);
router.put("/profile", updateProfile);

// Get available donations
router.get("/available-donations", getAvailableDonations);

// Claim a donation
router.post("/claim-donation", claimDonation);

// Get claimed donations
router.get("/claimed-donations", getClaimedDonations);

module.exports = router;
