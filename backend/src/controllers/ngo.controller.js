const NGO = require("../models/ngo.model");
const Donation = require("../models/donation.model");
const Claim = require("../models/claim.model");
const {
  formatResponse,
  handleError,
  createNotification,
  calculateDistance,
} = require("../utils/helpers");

// Get available donations for NGOs
const getAvailableDonations = async (req, res) => {
  try {
    console.log("Fetching available donations for NGO...");

    // Find all available donations
    const availableDonations = await Donation.find({
      status: "Posted",
    })
      .populate("restaurantId", "name address phone")
      .sort({ createdAt: -1 });

    console.log(`Found ${availableDonations.length} available donations`);

    res.json(
      formatResponse(
        true,
        "Available donations retrieved successfully",
        availableDonations
      )
    );
  } catch (error) {
    console.error("Error in getAvailableDonations:", error);
    const errorResponse = handleError(error);
    res.status(500).json(errorResponse);
  }
};

// Get NGO dashboard data
const getDashboard = async (req, res) => {
  try {
    const ngoId = req.user._id;

    // Get active claims
    const activeClaims = await Donation.find({
      claimedBy: ngoId,
      status: "Claimed",
    })
      .populate("restaurantId", "name address phone")
      .sort({ claimedAt: -1 });

    // Get completed claims
    const completedClaims = await Donation.find({
      claimedBy: ngoId,
      status: "Completed",
    })
      .sort({ completedAt: -1 })
      .limit(5)
      .populate("restaurantId", "name address phone");

    // Calculate impact stats
    const totalMeals = completedClaims.reduce((sum, donation) => {
      return sum + parseInt(donation.quantity);
    }, 0);

    const co2Saved = totalMeals * 2.5; // Assuming 2.5kg CO2 saved per meal

    res.json(
      formatResponse(true, "Dashboard data retrieved successfully", {
        impactStats: {
          mealsDelivered: totalMeals,
          co2Saved: `${co2Saved} kg`,
          peopleFed: totalMeals,
        },
        activeClaims,
        completedClaims,
      })
    );
  } catch (error) {
    console.error("Error in getDashboard:", error);
    const errorResponse = handleError(error);
    res.status(500).json(errorResponse);
  }
};

// Claim a donation
const claimDonation = async (req, res) => {
  try {
    const { donationId } = req.body;
    const ngoId = req.user._id;

    // Check if donation exists and is available
    const donation = await Donation.findById(donationId);
    if (!donation) {
      return res.status(404).json(formatResponse(false, "Donation not found"));
    }

    if (donation.status !== "Posted") {
      return res
        .status(400)
        .json(formatResponse(false, "Donation is not available for claiming"));
    }

    // Update donation status
    donation.status = "Claimed";
    donation.claimedBy = ngoId;
    donation.claimedAt = new Date();
    await donation.save();

    res
      .status(200)
      .json(formatResponse(true, "Donation claimed successfully", donation));
  } catch (error) {
    console.error("Error in claimDonation:", error);
    const errorResponse = handleError(error);
    res.status(500).json(errorResponse);
  }
};

// Update claim status
const updateClaimStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, impactReport } = req.body;

    const claim = await Claim.findOne({
      _id: id,
      ngoId: req.user._id,
    });

    if (!claim) {
      return res.status(404).json({
        success: false,
        message: "Claim not found",
      });
    }

    claim.status = status;
    if (impactReport) {
      claim.impactReport = impactReport;
    }
    await claim.save();

    // Update donation status if claim is completed
    if (status === "Completed") {
      const donation = await Donation.findById(claim.donationId);
      donation.status = "Completed";
      await donation.save();

      // Notify restaurant
      await createNotification(
        donation.restaurantId,
        "restaurant",
        "Donation Completed",
        `The donation has been completed by ${req.user.name}`,
        "impact"
      );
    }

    res.json(formatResponse(true, "Claim status updated successfully", claim));
  } catch (error) {
    const errorResponse = handleError(error);
    res.status(400).json(errorResponse);
  }
};

// Update NGO profile
const updateProfile = async (req, res) => {
  try {
    const ngoId = req.user._id;
    const updates = req.body;

    const ngo = await NGO.findByIdAndUpdate(
      ngoId,
      { $set: updates },
      { new: true, runValidators: true }
    );

    if (!ngo) {
      return res
        .status(404)
        .json(formatResponse(false, "NGO profile not found"));
    }

    res.json(formatResponse(true, "NGO profile updated successfully", ngo));
  } catch (error) {
    console.error("Error in updateProfile:", error);
    const errorResponse = handleError(error);
    res.status(500).json(errorResponse);
  }
};

// Get NGO profile
const getProfile = async (req, res) => {
  try {
    const ngoId = req.user._id;
    const ngo = await NGO.findById(ngoId);

    if (!ngo) {
      return res
        .status(404)
        .json(formatResponse(false, "NGO profile not found"));
    }

    res.json(formatResponse(true, "NGO profile retrieved successfully", ngo));
  } catch (error) {
    console.error("Error in getProfile:", error);
    const errorResponse = handleError(error);
    res.status(500).json(errorResponse);
  }
};

// Get claimed donations
const getClaimedDonations = async (req, res) => {
  try {
    const ngoId = req.user._id;

    const claimedDonations = await Donation.find({
      claimedBy: ngoId,
      status: { $in: ["Claimed", "Completed"] },
    })
      .populate("restaurantId", "name address phone")
      .sort({ claimedAt: -1 });

    res.json(
      formatResponse(
        true,
        "Claimed donations retrieved successfully",
        claimedDonations
      )
    );
  } catch (error) {
    console.error("Error in getClaimedDonations:", error);
    const errorResponse = handleError(error);
    res.status(500).json(errorResponse);
  }
};

module.exports = {
  getAvailableDonations,
  getDashboard,
  claimDonation,
  updateClaimStatus,
  updateProfile,
  getProfile,
  getClaimedDonations,
};
