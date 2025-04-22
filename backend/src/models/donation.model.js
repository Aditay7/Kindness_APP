const mongoose = require("mongoose");

const donationSchema = new mongoose.Schema(
  {
    restaurantId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Restaurant",
      required: [true, "Restaurant ID is required"],
    },
    foodType: {
      type: String,
      required: [true, "Food type is required"],
      enum: ["Vegetarian", "Non-Vegetarian", "Vegan", "Gluten-Free", "Halal", "Kosher"],
    },
    quantity: {
      type: String,
      required: [true, "Quantity is required"],
    },
    status: {
      type: String,
      required: [true, "Status is required"],
      enum: ["Posted", "Claimed", "Completed"],
      default: "Posted",
    },
    claimedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "NGO",
    },
    claimedAt: {
      type: Date,
    },
    allergens: [
      {
        type: String,
      },
    ],
    images: [
      {
        type: String,
        required: [true, "At least one image is required"],
      },
    ],
    pickupDeadline: {
      type: Date,
      required: [true, "Pickup deadline is required"],
    },
    notes: {
      type: String,
    },
  },
  {
    timestamps: true,
  }
);

// Index for status-based queries
donationSchema.index({ status: 1 });

// Index for restaurant-based queries
donationSchema.index({ restaurantId: 1 });

// Index for NGO-based queries
donationSchema.index({ claimedBy: 1 });

const Donation = mongoose.model("Donation", donationSchema);

module.exports = Donation;
