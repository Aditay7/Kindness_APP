const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      required: [true, "User ID is required"],
      refPath: "userType",
    },
    userType: {
      type: String,
      required: [true, "User type is required"],
      enum: ["restaurant", "ngo"],
    },
    title: {
      type: String,
      required: [true, "Notification title is required"],
    },
    message: {
      type: String,
      required: [true, "Notification message is required"],
    },
    type: {
      type: String,
      required: [true, "Notification type is required"],
      enum: ["donation", "claim", "pickup", "impact"],
    },
    read: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Index for user-based queries
notificationSchema.index({ userId: 1, userType: 1 });

// Index for unread notifications
notificationSchema.index({ read: 1 });

const Notification = mongoose.model("Notification", notificationSchema);

module.exports = Notification;
