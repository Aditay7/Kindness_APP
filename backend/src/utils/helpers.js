const jwt = require("jsonwebtoken");
const cloudinary = require("cloudinary").v2;
const Notification = require("../models/notification.model");

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// JWT Token Generation
const generateToken = (id, userType) => {
  return jwt.sign({ id, userType }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN,
  });
};

// Cloudinary Image Upload
const uploadImage = async (file) => {
  try {
    if (!file) {
      throw new Error("No file provided");
    }
    const result = await cloudinary.uploader.upload(file.path, {
      folder: "kindness",
      resource_type: "auto",
    });
    return result.secure_url;
  } catch (error) {
    console.error("Cloudinary upload error:", error);
    throw new Error("Error uploading image: " + error.message);
  }
};

// Create Notification
const createNotification = async (userId, userType, title, message, type) => {
  try {
    const notification = await Notification.create({
      userId,
      userType,
      title,
      message,
      type,
    });
    return notification;
  } catch (error) {
    console.error("Error creating notification:", error);
    return null;
  }
};

// Calculate Distance between two points
const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371; // Earth's radius in km
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};

const toRad = (value) => {
  return (value * Math.PI) / 180;
};

// Format Response
const formatResponse = (success, message, data = null) => {
  return {
    success,
    message,
    data,
  };
};

// Error Handler
const handleError = (error) => {
  if (error.name === "ValidationError") {
    return {
      success: false,
      message: "Validation Error",
      errors: Object.values(error.errors).map((err) => err.message),
    };
  }

  if (error.code === 11000) {
    return {
      success: false,
      message: "Duplicate field value entered",
    };
  }

  return {
    success: false,
    message: "Internal Server Error",
  };
};

module.exports = {
  generateToken,
  uploadImage,
  createNotification,
  calculateDistance,
  formatResponse,
  handleError,
};
