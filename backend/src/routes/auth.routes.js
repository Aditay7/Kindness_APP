const express = require("express");
const router = express.Router();
const {
  register,
  login,
  refreshToken,
} = require("../controllers/auth.controller");
const { auth } = require("../middleware/auth.middleware");

// Public routes
router.post("/register", register);
router.post("/login", login);

// Protected routes
router.post("/refresh-token", auth, refreshToken);

module.exports = router;
