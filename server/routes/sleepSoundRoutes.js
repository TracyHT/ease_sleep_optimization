import { Router } from "express";
const router = Router();
import {
  getAllSleepSounds,
  getSoundsByCategory,
  getSleepSoundById,
  createSleepSound,
  updateSleepSound,
  deleteSleepSound,
  incrementPopularity,
  getPopularSounds,
  initializeDefaultSounds
} from "../controllers/sleepSoundControllers.js";

// GET /api/sleep-sounds - Get all sleep sounds (with optional filters)
router.get("/", getAllSleepSounds);

// GET /api/sleep-sounds/popular - Get popular sounds
router.get("/popular", getPopularSounds);

// GET /api/sleep-sounds/category/:category - Get sounds by category
router.get("/category/:category", getSoundsByCategory);

// GET /api/sleep-sounds/:id - Get a specific sleep sound
router.get("/:id", getSleepSoundById);

// POST /api/sleep-sounds - Create a new sleep sound
router.post("/", createSleepSound);

// POST /api/sleep-sounds/initialize - Initialize default sounds (for seeding)
router.post("/initialize", initializeDefaultSounds);

// PUT /api/sleep-sounds/:id - Update a sleep sound
router.put("/:id", updateSleepSound);

// DELETE /api/sleep-sounds/:id - Delete a sleep sound (soft delete)
router.delete("/:id", deleteSleepSound);

// POST /api/sleep-sounds/:id/play - Increment popularity when sound is played
router.post("/:id/play", incrementPopularity);

export default router;