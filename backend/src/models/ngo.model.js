const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const ngoSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "NGO name is required"],
      trim: true,
    },
    email: {
      type: String,
      required: [true, "Email is required"],
      unique: true,
      trim: true,
      lowercase: true,
      match: [
        /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/,
        "Please enter a valid email",
      ],
    },
    password: {
      type: String,
      required: [true, "Password is required"],
      minlength: 6,
      select: false,
    },
    fcmToken: {
      type: String,
      default: null,
    },
    status: {
      type: String,
      enum: ["active", "inactive", "suspended"],
      default: "active",
    },
    ngoType: {
      type: String,
      required: [true, "NGO type is required"],
      enum: [
        "Homeless Shelter",
        "Animal Rescue",
        "Food Bank",
        "Community Kitchen",
        "Youth Center",
        "Senior Center",
        "Other",
      ],
    },
    address: {
      street: {
        type: String,
        required: [true, "Street address is required"],
      },
      city: {
        type: String,
        required: [true, "City is required"],
      },
      state: {
        type: String,
        required: [true, "State is required"],
      },
      country: {
        type: String,
        required: [true, "Country is required"],
      },
      coordinates: {
        latitude: {
          type: Number,
          required: [false, "Latitude is required"],
        },
        longitude: {
          type: Number,
          required: [false, "Longitude is required"],
        },
      },
      pincode: {
        type: String,
        required: [false, "Pincode is required"],
      },
    },
    phone: {
      type: String,
      required: [true, "Phone number is required"],
    },
    registrationNumber: {
      type: String,
      required: [true, "Registration number is required"],
    },
    preferredFoodTypes: [
      {
        type: String,
        enum: ["Vegetarian", "Non-Vegetarian", "Mixed"],
      },
    ],
    ngoTypes: [
      {
        type: String,
        enum: [
          "Homeless Shelter",
          "Animal Rescue",
          "Food Bank",
          "Community Kitchen",
          "Youth Center",
          "Senior Center",
          "Other",
        ],
      },
    ],
    serviceArea: {
      type: {
        type: String,
        enum: ["Polygon"],
        default: "Polygon",
      },
      coordinates: {
        type: [[[Number]]], // Array of arrays of [longitude, latitude] pairs
        required: [false, "Service area coordinates are required"],
      },
    },
    rating: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },
    isVerified: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Hash password before saving
ngoSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();

  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Method to compare password
ngoSchema.methods.comparePassword = async function (candidatePassword) {
  try {
    return await bcrypt.compare(candidatePassword, this.password);
  } catch (error) {
    throw error;
  }
};

// Index for geospatial queries
ngoSchema.index({ "address.coordinates": "2dsphere" });
ngoSchema.index({ serviceArea: "2dsphere" });

const NGO = mongoose.model("NGO", ngoSchema);

module.exports = NGO;
