const express = require("express");
const router = express.Router();
const multer = require("multer");
const upload = multer({ dest: "uploads/" });
const {
  auth,
  checkRole,
  authenticateToken,
} = require("../middleware/auth.middleware");
const {
  getDashboard,
  createDonation,
  getDonations,
  updateDonationStatus,
  updateProfile,
  getProfile,
} = require("../controllers/restaurant.controller");
const {
  uploadImage,
  formatResponse,
  handleError,
} = require("../utils/helpers");
const Restaurant = require("../models/restaurant.model");

// All routes require authentication and restaurant role
router.use(auth, checkRole("restaurant"));

// Dashboard
router.get("/dashboard", getDashboard);

// Image upload
router.post("/upload", upload.single("image"), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No image file provided",
      });
    }

    const imageUrl = await uploadImage(req.file);
    res.json(
      formatResponse(true, "Image uploaded successfully", { url: imageUrl })
    );
  } catch (error) {
    console.error("Image upload error:", error);
    const errorResponse = handleError(error);
    res.status(400).json(errorResponse);
  }
});

// Donations
router.post("/donations", createDonation);
router.get("/donations", getDonations);
router.put("/donations/:id", updateDonationStatus);

// Profile
router.get("/profile", getProfile);
router.put("/profile", updateProfile);

module.exports = router;
