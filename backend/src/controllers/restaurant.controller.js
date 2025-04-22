const Restaurant = require("../models/restaurant.model");
const Donation = require("../models/donation.model");
const Claim = require("../models/claim.model");
const {
  formatResponse,
  handleError,
  createNotification,
} = require("../utils/helpers");
const notificationService = require("../services/notification.service");

// Get restaurant dashboard data
const getDashboard = async (req, res) => {
  try {
    const restaurantId = req.user._id;

    // Get active donations
    const activeDonations = await Donation.find({
      restaurantId,
      status: { $in: ["Posted", "Claimed"] },
    }).populate("ngoId", "name");

    // Get recent donations
    const recentDonations = await Donation.find({
      restaurantId,
      status: "Completed",
    })
      .sort({ createdAt: -1 })
      .limit(5)
      .populate("ngoId", "name");

    // Calculate impact stats
    const completedDonations = await Donation.find({
      restaurantId,
      status: "Completed",
    });

    const totalMeals = completedDonations.reduce((sum, donation) => {
      const meals = parseInt(donation.quantity);
      return sum + meals;
    }, 0);

    const co2Saved = totalMeals * 2.5; // Assuming 2.5kg CO2 saved per meal

    res.json(
      formatResponse(true, "Dashboard data retrieved successfully", {
        impactStats: {
          mealsDonated: totalMeals,
          co2Saved: `${co2Saved} kg`,
          peopleFed: totalMeals,
        },
        activeDonations,
        recentDonations,
      })
    );
  } catch (error) {
    const errorResponse = handleError(error);
    res.status(400).json(errorResponse);
  }
};

// Create a new donation
const createDonation = async (req, res) => {
  try {
    const donation = await Donation.create({
      ...req.body,
      restaurantId: req.user._id,
      status: "Posted",
    });

    // Send FCM notification to all NGOs
    await notificationService.sendNotificationToNGOs(
      req.user.name,
      donation.foodType,
      donation._id
    );

    res
      .status(201)
      .json(formatResponse(true, "Donation created successfully", donation));
  } catch (error) {
    const errorResponse = handleError(error);
    res.status(400).json(errorResponse);
  }
};

// Get restaurant's donations
const getDonations = async (req, res) => {
  try {
    const restaurantId = req.user._id;
    const { status } = req.query;

    const query = { restaurantId };
    if (status) {
      query.status = status;
    }

    const donations = await Donation.find(query)
      .populate("restaurantId", "name address phone")
      .populate("claimedBy", "name phone address")
      .sort({ createdAt: -1 });

    res.json(
      formatResponse(true, "Donations retrieved successfully", donations)
    );
  } catch (error) {
    console.error("Error in getDonations:", error);
    const errorResponse = handleError(error);
    res.status(500).json(errorResponse);
  }
};

// Update donation status
const updateDonationStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const donation = await Donation.findOne({
      _id: id,
      restaurantId: req.user._id,
    });

    if (!donation) {
      return res.status(404).json({
        success: false,
        message: "Donation not found",
      });
    }

    donation.status = status;
    await donation.save();

    // Notify NGO if status changed to completed
    if (status === "Completed" && donation.ngoId) {
      await createNotification(
        donation.ngoId,
        "ngo",
        "Donation Completed",
        `The donation from ${req.user.name} has been completed`,
        "donation"
      );
    }

    res.json(
      formatResponse(true, "Donation status updated successfully", donation)
    );
  } catch (error) {
    const errorResponse = handleError(error);
    res.status(400).json(errorResponse);
  }
};

// Update restaurant profile
const updateProfile = async (req, res) => {
  try {
    const updates = req.body;
    const restaurant = await Restaurant.findByIdAndUpdate(
      req.user._id,
      { $set: updates },
      { new: true, runValidators: true }
    ).select("-password");

    res.json(formatResponse(true, "Profile updated successfully", restaurant));
  } catch (error) {
    const errorResponse = handleError(error);
    res.status(400).json(errorResponse);
  }
};

// Get restaurant profile
const getProfile = async (req, res) => {
  try {
    const restaurantId = req.user.id;
    const restaurant = await Restaurant.findById(restaurantId).select(
      "-password"
    );

    if (!restaurant) {
      return res.status(404).json({
        success: false,
        message: "Restaurant not found",
      });
    }

    res.json({
      success: true,
      data: restaurant,
    });
  } catch (error) {
    console.error("Error fetching restaurant profile:", error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  getDashboard,
  createDonation,
  getDonations,
  updateDonationStatus,
  updateProfile,
  getProfile,
};
