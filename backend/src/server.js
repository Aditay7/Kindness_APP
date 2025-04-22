const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const helmet = require("helmet");
const socketio = require("socket.io");
const http = require("http");
require("dotenv").config();
const path = require("path");

const app = express();
const server = http.createServer(app);
const io = socketio(server, {
  cors: {
    origin: "*", // Allow all origins in development
    methods: ["GET", "POST", "PUT", "DELETE"],
    credentials: true,
  },
});

// Configure CORS before other middleware
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization", "Accept"],
    credentials: true,
  })
);

// Security middleware
app.use(helmet());

// Parse JSON bodies
app.use(express.json());

// Add request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  console.log("Request Headers:", req.headers);
  console.log("Request Body:", req.body);
  next();
});

// Health check endpoint
app.get("/api/health", (req, res) => {
  res.json({
    status: "ok",
    timestamp: new Date().toISOString(),
    mongodb:
      mongoose.connection.readyState === 1 ? "connected" : "disconnected",
  });
});

// Serve static files from uploads directory
app.use("/uploads", express.static(path.join(__dirname, "../uploads")));

// Routes
const authRoutes = require("./routes/auth.routes");
const restaurantRoutes = require("./routes/restaurant.routes");
const ngoRoutes = require("./routes/ngo.routes");
const notificationRoutes = require("./routes/notification.routes");

app.use("/api/auth", authRoutes);
app.use("/api/restaurant", restaurantRoutes);
app.use("/api/ngo", ngoRoutes);
app.use("/api/notifications", notificationRoutes);

// WebSocket connection handling
io.on("connection", (socket) => {
  console.log("New client connected");

  socket.on("join", ({ userId, userType }) => {
    socket.join(`${userType}-${userId}`);
    console.log(`${userType} ${userId} joined their room`);
  });

  socket.on("track_location", (data) => {
    io.to(data.room).emit("volunteer_location", data);
  });

  socket.on("update_status", (data) => {
    io.to(data.room).emit("status_update", data);
  });

  socket.on("disconnect", () => {
    console.log("Client disconnected");
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: "Something went wrong!",
  });
});

// Database connection
mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => console.log("Connected to MongoDB"))
  .catch((err) => console.error("MongoDB connection error:", err));

const PORT = process.env.PORT || 5000;
const HOST = "0.0.0.0"; // Listen on all available network interfaces

server.listen(PORT, HOST, () => {
  console.log(`Server is running on http://${HOST}:${PORT}`);
  console.log(`Access the server at http://localhost:${PORT}`);
  console.log(`Or from other devices at http://YOUR_IP:${PORT}`);
});
