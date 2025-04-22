const Notification = require("../models/notification.model");
const { formatResponse, handleError } = require("../utils/helpers");

// Get user's notifications
const getNotifications = async (req, res) => {
  try {
    const { read } = req.query;
    const query = {
      userId: req.user._id,
      userType: req.userType,
    };

    if (read !== undefined) {
      query.read = read === "true";
    }

    const notifications = await Notification.find(query)
      .sort({ createdAt: -1 })
      .limit(50);

    res.json(
      formatResponse(
        true,
        "Notifications retrieved successfully",
        notifications
      )
    );
  } catch (error) {
    const errorResponse = handleError(error);
    res.status(400).json(errorResponse);
  }
};

// Mark notification as read
const markAsRead = async (req, res) => {
  try {
    const { id } = req.params;

    const notification = await Notification.findOneAndUpdate(
      {
        _id: id,
        userId: req.user._id,
        userType: req.userType,
      },
      { read: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found",
      });
    }

    res.json(formatResponse(true, "Notification marked as read", notification));
  } catch (error) {
    const errorResponse = handleError(error);
    res.status(400).json(errorResponse);
  }
};

// Mark all notifications as read
const markAllAsRead = async (req, res) => {
  try {
    await Notification.updateMany(
      {
        userId: req.user._id,
        userType: req.userType,
        read: false,
      },
      { read: true }
    );

    res.json(formatResponse(true, "All notifications marked as read"));
  } catch (error) {
    const errorResponse = handleError(error);
    res.status(400).json(errorResponse);
  }
};

// Delete notification
const deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;

    const notification = await Notification.findOneAndDelete({
      _id: id,
      userId: req.user._id,
      userType: req.userType,
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found",
      });
    }

    res.json(formatResponse(true, "Notification deleted successfully"));
  } catch (error) {
    const errorResponse = handleError(error);
    res.status(400).json(errorResponse);
  }
};

module.exports = {
  getNotifications,
  markAsRead,
  markAllAsRead,
  deleteNotification,
};
