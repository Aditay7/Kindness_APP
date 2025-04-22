const jwt = require("jsonwebtoken");
const Restaurant = require("../models/restaurant.model");
const NGO = require("../models/ngo.model");

const auth = async (req, res, next) => {
  try {
    const token = req.header("Authorization")?.replace("Bearer ", "");

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "No authentication token, access denied",
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const { id, userType } = decoded;

    let user;
    if (userType === "restaurant") {
      user = await Restaurant.findById(id).select("-password");
    } else if (userType === "ngo") {
      user = await NGO.findById(id).select("-password");
    }

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "User not found",
      });
    }

    req.user = user;
    req.userType = userType;
    next();
  } catch (error) {
    res.status(401).json({
      success: false,
      message: "Token is invalid or expired",
    });
  }
};

const checkRole = (...roles) => {
  return (req, res, next) => {
    if (
      !roles
        .map((role) => role.toLowerCase())
        .includes(req.userType.toLowerCase())
    ) {
      return res.status(403).json({
        success: false,
        message: "Access denied. Insufficient permissions.",
      });
    }
    next();
  };
};

module.exports = {
  auth,
  checkRole,
};
