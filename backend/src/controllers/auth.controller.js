const Restaurant = require("../models/restaurant.model");
const NGO = require("../models/ngo.model");
const {
  generateToken,
  formatResponse,
  handleError,
} = require("../utils/helpers");

const register = async (req, res) => {
  try {
    const { userType, ...userData } = req.body;

    if (!["restaurant", "ngo"].includes(userType)) {
      return res.status(400).json({
        success: false,
        message: "Invalid user type",
      });
    }

    // Check if user already exists
    const existingUser = await (userType === "restaurant"
      ? Restaurant
      : NGO
    ).findOne({ email: userData.email });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: "User already exists",
      });
    }

    // Set status to active for new users
    userData.status = "active";

    // Create new user
    const user = await (userType === "restaurant" ? Restaurant : NGO).create(
      userData
    );

    // Generate token
    const token = generateToken(user._id, userType);

    // Remove password from response
    const userResponse = user.toObject();
    delete userResponse.password;

    res.status(201).json(
      formatResponse(true, "Registration successful", {
        token,
        user: userResponse,
      })
    );
  } catch (error) {
    console.error("Registration error:", error);
    const errorResponse = handleError(error);
    res.status(400).json(errorResponse);
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user by email
    const restaurant = await Restaurant.findOne({ email }).select("+password");
    const ngo = await NGO.findOne({ email }).select("+password");

    const user = restaurant || ngo;
    const userType = restaurant ? "restaurant" : "ngo";

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials",
      });
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials",
      });
    }

    // Generate token
    const token = generateToken(user._id, userType);

    // Remove password from response
    const userResponse = user.toObject();
    delete userResponse.password;

    res.json(
      formatResponse(true, "Login successful", {
        token,
        user: userResponse,
      })
    );
  } catch (error) {
    const errorResponse = handleError(error);
    res.status(400).json(errorResponse);
  }
};

const refreshToken = async (req, res) => {
  try {
    const { id, userType } = req.user;
    const token = generateToken(id, userType);

    res.json(formatResponse(true, "Token refreshed successfully", { token }));
  } catch (error) {
    const errorResponse = handleError(error);
    res.status(400).json(errorResponse);
  }
};

module.exports = {
  register,
  login,
  refreshToken,
};
