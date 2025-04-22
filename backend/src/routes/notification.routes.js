const express = require("express");
const router = express.Router();
const { auth } = require("../middleware/auth.middleware");
const {
  getNotifications,
  markAsRead,
  markAllAsRead,
  deleteNotification,
} = require("../controllers/notification.controller");
const notificationService = require("../services/notification.service");

// All routes require authentication
router.use(auth);

// Update FCM token
router.post("/update-token", async (req, res) => {
  try {
    console.log("Received token update request");
    console.log("User ID:", req.user._id);
    console.log("User Type:", req.userType);
    console.log("Request Body:", req.body);

    // Check for both token and fcmToken in request body
    const token = req.body.token || req.body.fcmToken;

    if (!token) {
      console.log("No token provided in request");
      return res.status(400).json({
        success: false,
        message: "Token is required",
      });
    }

    console.log("Calling updateFCMToken service with token:", token);
    const success = await notificationService.updateFCMToken(
      req.user._id,
      token
    );

    console.log("Token update result:", success);
    if (success) {
      res.json({ success: true, message: "FCM token updated successfully" });
    } else {
      res
        .status(400)
        .json({ success: false, message: "Failed to update FCM token" });
    }
  } catch (error) {
    console.error("Error updating FCM token:", error);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

// Get notifications
router.get("/", getNotifications);

// Mark notifications as read
router.put("/:id/read", markAsRead);
router.put("/read-all", markAllAsRead);

// Delete notification
router.delete("/:id", deleteNotification);

module.exports = router;
