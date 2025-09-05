import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import dotenv from "dotenv";
import SleepSound from "./models/sleepSound.model.js";

// Load environment variables
dotenv.config();

const app = express();

// Middleware
app.use(express.json());
app.use(cors());

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB connected"))
  .catch(err => console.error("MongoDB connection error:", err));

// Routes
app.get("/", (req, res) => {
  res.json({ message: "Sleep Sound API Server is running!" });
});

// GET all sleep sounds
app.get("/api/sleep-sounds", async (req, res) => {
  try {
    const { category, isPremium } = req.query;
    const filter = { isActive: true };
    
    if (category) filter.category = category;
    if (isPremium !== undefined) filter.isPremium = isPremium === 'true';
    
    const sounds = await SleepSound.find(filter)
      .sort({ popularity: -1, createdAt: -1 })
      .select('-__v');
    
    res.status(200).json({
      success: true,
      count: sounds.length,
      data: sounds
    });
  } catch (error) {
    console.error('Error fetching sleep sounds:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// GET sound by ID
app.get("/api/sleep-sounds/:id", async (req, res) => {
  try {
    const sound = await SleepSound.findOne({ 
      id: req.params.id, 
      isActive: true 
    }).select('-__v');
    
    if (!sound) {
      return res.status(404).json({
        success: false,
        message: 'Sound not found'
      });
    }
    
    res.status(200).json({
      success: true,
      data: sound
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// POST increment popularity
app.post("/api/sleep-sounds/:id/play", async (req, res) => {
  try {
    const sound = await SleepSound.findOneAndUpdate(
      { id: req.params.id, isActive: true },
      { $inc: { popularity: 1 }, updatedAt: Date.now() },
      { new: true }
    );
    
    if (!sound) {
      return res.status(404).json({
        success: false,
        message: 'Sound not found'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Popularity updated',
      popularity: sound.popularity
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Test the API at: http://localhost:${PORT}/api/sleep-sounds`);
});