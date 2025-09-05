import mongoose from "mongoose";

const sleepSoundSchema = new mongoose.Schema({
  id: {
    type: String,
    required: true,
    unique: true
  },
  title: {
    type: String,
    required: true
  },
  subtitle: {
    type: String,
    required: true
  },
  category: {
    type: String,
    required: true,
    enum: ['Nature', 'White Noise', 'Meditation', 'Binaural Beats', 'Instrumental', 'Ambient']
  },
  audioPath: {
    type: String,
    required: true
  },
  imagePath: {
    type: String,
    default: 'lib/assets/images/placeholder.jpg'
  },
  duration: {
    type: Number, // Duration in minutes
    required: true
  },
  isLooping: {
    type: Boolean,
    default: true
  },
  isPremium: {
    type: Boolean,
    default: false
  },
  description: {
    type: String,
    default: ''
  },
  tags: [{
    type: String
  }],
  popularity: {
    type: Number,
    default: 0
  },
  isActive: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Update the updatedAt field before saving
sleepSoundSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Create indexes for better query performance
sleepSoundSchema.index({ category: 1 });
sleepSoundSchema.index({ isActive: 1 });
sleepSoundSchema.index({ popularity: -1 });
sleepSoundSchema.index({ isPremium: 1 });

const SleepSound = mongoose.model("SleepSound", sleepSoundSchema);

export default SleepSound;