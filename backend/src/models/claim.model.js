const mongoose = require("mongoose");

const claimSchema = new mongoose.Schema(
  {
    donationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Donation",
      required: [true, "Donation ID is required"],
    },
    ngoId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "NGO",
      required: [true, "NGO ID is required"],
    },
    status: {
      type: String,
      required: [true, "Status is required"],
      enum: ["Pending", "Accepted", "Completed"],
      default: "Pending",
    },
    pickupTime: {
      type: Date,
      required: [true, "Pickup time is required"],
    },
    volunteerLocation: {
      type: {
        type: String,
        enum: ["Point"],
        default: "Point",
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        required: [true, "Volunteer location coordinates are required"],
      },
    },
    impactReport: {
      mealsDelivered: {
        type: Number,
        required: [true, "Number of meals delivered is required"],
      },
      photos: [
        {
          type: String,
        },
      ],
      co2Saved: {
        type: Number,
        required: [true, "CO2 saved is required"],
      },
      notes: {
        type: String,
      },
    },
  },
  {
    timestamps: true,
  }
);

// Index for geospatial queries
claimSchema.index({ volunteerLocation: "2dsphere" });

// Index for status-based queries
claimSchema.index({ status: 1 });

// Index for NGO-based queries
claimSchema.index({ ngoId: 1 });

// Index for donation-based queries
claimSchema.index({ donationId: 1 });

const Claim = mongoose.model("Claim", claimSchema);

module.exports = Claim;
