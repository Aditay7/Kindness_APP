const admin = require("../config/firebase");
const NGO = require("../models/ngo.model");

class NotificationService {
  async updateFCMToken(userId, token) {
    try {
      console.log("Updating FCM token for NGO:", userId);
      console.log("Token:", token);

      // First check if NGO exists
      const ngo = await NGO.findById(userId);
      console.log("Found NGO:", ngo ? "Yes" : "No");

      if (!ngo) {
        console.log("NGO not found with ID:", userId);
        return false;
      }

      console.log("Current NGO status:", ngo.status);
      console.log("Current NGO FCM token:", ngo.fcmToken);

      const updatedNGO = await NGO.findByIdAndUpdate(
        userId,
        { fcmToken: token },
        { new: true }
      );

      console.log("Updated NGO:", updatedNGO);
      console.log("New NGO FCM token:", updatedNGO.fcmToken);
      return true;
    } catch (error) {
      console.error("Error updating FCM token:", error);
      return false;
    }
  }

  async sendNotificationToNGOs(restaurantName, foodType, donationId) {
    try {
      console.log("Sending notifications for donation");
      console.log("Restaurant:", restaurantName);
      console.log("Food Type:", foodType);
      console.log("Donation ID:", donationId);

      // Get all active NGOs with FCM tokens
      const ngos = await NGO.find({
        status: "active",
        fcmToken: { $exists: true, $ne: null },
      });

      console.log("Found NGOs with FCM tokens:", ngos.length);
      console.log(
        "NGOs:",
        ngos.map((ngo) => ({
          id: ngo._id,
          name: ngo.name,
          status: ngo.status,
          hasToken: !!ngo.fcmToken,
        }))
      );

      if (ngos.length === 0) {
        console.log("No active NGOs with FCM tokens found");
        return;
      }

      const tokens = ngos.map((ngo) => ngo.fcmToken);
      console.log("FCM Tokens to send to:", tokens);

      const message = {
        notification: {
          title: `${restaurantName} Posted a new donation of ${foodType}`,
          body: "Tap to view details",
        },
        data: {
          restaurantName,
          foodType,
          type: "new_donation",
          donationId: donationId.toString(),
        },
      };

      // Send to each token individually
      for (const token of tokens) {
        try {
          console.log("Sending notification to token:", token);
          const response = await admin.messaging().send({
            ...message,
            token: token,
          });
          console.log("Successfully sent notification to token:", token);
          console.log("Response:", response);
        } catch (error) {
          console.error("Error sending notification to token:", token, error);
          // If token is invalid, remove it from the NGO document
          if (error.code === "messaging/invalid-registration-token") {
            console.log("Invalid token, removing from NGO document");
            await NGO.findOneAndUpdate({ fcmToken: token }, { fcmToken: null });
          }
        }
      }

      return true;
    } catch (error) {
      console.error("Error in sendNotificationToNGOs:", error);
      throw error;
    }
  }
}

module.exports = new NotificationService();
