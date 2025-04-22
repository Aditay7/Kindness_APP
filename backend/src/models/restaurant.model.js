const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const restaurantSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Restaurant name is required"],
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
    },
    phone: {
      type: String,
      required: [true, "Phone number is required"],
    },
    taxId: {
      type: String,
      required: [true, "Tax ID is required"],
    },
    logoUrl: {
      type: String,
    },
    rating: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },
    foodSafetyCertificates: [
      {
        type: String,
      },
    ],
  },
  {
    timestamps: true,
  }
);

// Hash password before saving
restaurantSchema.pre("save", async function (next) {
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
restaurantSchema.methods.comparePassword = async function (candidatePassword) {
  try {
    return await bcrypt.compare(candidatePassword, this.password);
  } catch (error) {
    throw error;
  }
};

// Index for geospatial queries
restaurantSchema.index({ "address.coordinates": "2dsphere" });

const Restaurant = mongoose.model("Restaurant", restaurantSchema);

module.exports = Restaurant;
