import SleepSound from "../models/sleepSound.model.js";

// Get all sleep sounds
export const getAllSleepSounds = async (req, res) => {
  try {
    const { category, isPremium, isActive = true } = req.query;
    
    // Build filter object
    const filter = { isActive: isActive === 'true' };
    
    if (category) {
      filter.category = category;
    }
    
    if (isPremium !== undefined) {
      filter.isPremium = isPremium === 'true';
    }
    
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
      message: 'Error fetching sleep sounds',
      error: error.message
    });
  }
};

// Get sleep sounds by category
export const getSoundsByCategory = async (req, res) => {
  try {
    const { category } = req.params;
    const sounds = await SleepSound.find({ 
      category: category, 
      isActive: true 
    })
    .sort({ popularity: -1 })
    .select('-__v');
    
    res.status(200).json({
      success: true,
      category: category,
      count: sounds.length,
      data: sounds
    });
  } catch (error) {
    console.error('Error fetching sounds by category:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching sounds by category',
      error: error.message
    });
  }
};

// Get a single sleep sound by ID
export const getSleepSoundById = async (req, res) => {
  try {
    const { id } = req.params;
    const sound = await SleepSound.findOne({ id: id, isActive: true }).select('-__v');
    
    if (!sound) {
      return res.status(404).json({
        success: false,
        message: 'Sleep sound not found'
      });
    }
    
    res.status(200).json({
      success: true,
      data: sound
    });
  } catch (error) {
    console.error('Error fetching sleep sound:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching sleep sound',
      error: error.message
    });
  }
};

// Create a new sleep sound
export const createSleepSound = async (req, res) => {
  try {
    const soundData = req.body;
    
    // Check if sound with same ID already exists
    const existingSound = await SleepSound.findOne({ id: soundData.id });
    if (existingSound) {
      return res.status(400).json({
        success: false,
        message: 'Sleep sound with this ID already exists'
      });
    }
    
    const newSound = new SleepSound(soundData);
    const savedSound = await newSound.save();
    
    res.status(201).json({
      success: true,
      message: 'Sleep sound created successfully',
      data: savedSound
    });
  } catch (error) {
    console.error('Error creating sleep sound:', error);
    res.status(400).json({
      success: false,
      message: 'Error creating sleep sound',
      error: error.message
    });
  }
};

// Update a sleep sound
export const updateSleepSound = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;
    
    const updatedSound = await SleepSound.findOneAndUpdate(
      { id: id },
      { ...updateData, updatedAt: Date.now() },
      { new: true, runValidators: true }
    ).select('-__v');
    
    if (!updatedSound) {
      return res.status(404).json({
        success: false,
        message: 'Sleep sound not found'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Sleep sound updated successfully',
      data: updatedSound
    });
  } catch (error) {
    console.error('Error updating sleep sound:', error);
    res.status(400).json({
      success: false,
      message: 'Error updating sleep sound',
      error: error.message
    });
  }
};

// Delete a sleep sound (soft delete by setting isActive to false)
export const deleteSleepSound = async (req, res) => {
  try {
    const { id } = req.params;
    
    const deletedSound = await SleepSound.findOneAndUpdate(
      { id: id },
      { isActive: false, updatedAt: Date.now() },
      { new: true }
    );
    
    if (!deletedSound) {
      return res.status(404).json({
        success: false,
        message: 'Sleep sound not found'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Sleep sound deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting sleep sound:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting sleep sound',
      error: error.message
    });
  }
};

// Increment popularity (when a sound is played)
export const incrementPopularity = async (req, res) => {
  try {
    const { id } = req.params;
    
    const sound = await SleepSound.findOneAndUpdate(
      { id: id, isActive: true },
      { $inc: { popularity: 1 }, updatedAt: Date.now() },
      { new: true }
    ).select('-__v');
    
    if (!sound) {
      return res.status(404).json({
        success: false,
        message: 'Sleep sound not found'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Popularity updated successfully',
      data: sound
    });
  } catch (error) {
    console.error('Error updating popularity:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating popularity',
      error: error.message
    });
  }
};

// Get popular sounds (top 10)
export const getPopularSounds = async (req, res) => {
  try {
    const sounds = await SleepSound.find({ isActive: true })
      .sort({ popularity: -1 })
      .limit(10)
      .select('-__v');
    
    res.status(200).json({
      success: true,
      count: sounds.length,
      data: sounds
    });
  } catch (error) {
    console.error('Error fetching popular sounds:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching popular sounds',
      error: error.message
    });
  }
};

// Initialize default sounds (for seeding the database)
export const initializeDefaultSounds = async (req, res) => {
  try {
    // Check if sounds already exist
    const existingSounds = await SleepSound.countDocuments();
    if (existingSounds > 0) {
      return res.status(200).json({
        success: true,
        message: 'Database already contains sounds',
        count: existingSounds
      });
    }
    
    // Default sounds data
    const defaultSounds = [
      {
        id: "rain_heavy",
        title: "Heavy Rain",
        subtitle: "Intense rainfall sounds",
        category: "Nature",
        audioPath: "audio/rain_heavy.mp3",
        imagePath: "lib/assets/images/rain.jpg",
        duration: 30,
        isLooping: true,
        isPremium: false,
        description: "Relaxing heavy rain sounds for deep sleep",
        tags: ["rain", "nature", "relaxing"],
        popularity: 95
      },
      {
        id: "rain_light",
        title: "Light Rain",
        subtitle: "Gentle rainfall sounds",
        category: "Nature",
        audioPath: "audio/rain_light.mp3",
        imagePath: "lib/assets/images/rain.jpg",
        duration: 30,
        isLooping: true,
        isPremium: false,
        description: "Soft rain sounds for peaceful sleep",
        tags: ["rain", "nature", "gentle"],
        popularity: 88
      },
      {
        id: "ocean_waves",
        title: "Ocean Waves",
        subtitle: "Calming sea sounds",
        category: "Nature",
        audioPath: "audio/ocean_waves.mp3",
        imagePath: "lib/assets/images/ocean.jpg",
        duration: 45,
        isLooping: true,
        isPremium: false,
        description: "Soothing ocean waves for relaxation",
        tags: ["ocean", "waves", "nature"],
        popularity: 92
      },
      {
        id: "forest_ambient",
        title: "Forest Ambient",
        subtitle: "Peaceful forest sounds",
        category: "Nature",
        audioPath: "audio/forest_ambient.mp3",
        imagePath: "lib/assets/images/forest.jpg",
        duration: 40,
        isLooping: true,
        isPremium: false,
        description: "Immersive forest ambience for deep rest",
        tags: ["forest", "birds", "nature"],
        popularity: 75
      },
      {
        id: "white_noise",
        title: "White Noise",
        subtitle: "Pure white noise",
        category: "White Noise",
        audioPath: "audio/white_noise.mp3",
        imagePath: "lib/assets/images/white_noise.jpg",
        duration: 60,
        isLooping: true,
        isPremium: false,
        description: "Classic white noise for concentration and sleep",
        tags: ["white_noise", "focus", "sleep"],
        popularity: 90
      },
      {
        id: "pink_noise",
        title: "Pink Noise",
        subtitle: "Balanced frequency noise",
        category: "White Noise",
        audioPath: "audio/pink_noise.mp3",
        imagePath: "lib/assets/images/pink_noise.jpg",
        duration: 60,
        isLooping: true,
        isPremium: false,
        description: "Pink noise for improved sleep quality",
        tags: ["pink_noise", "balance", "sleep"],
        popularity: 78
      },
      {
        id: "brown_noise",
        title: "Brown Noise",
        subtitle: "Deep, rumbling noise",
        category: "White Noise",
        audioPath: "audio/brown_noise.mp3",
        imagePath: "lib/assets/images/brown_noise.jpg",
        duration: 60,
        isLooping: true,
        isPremium: false,
        description: "Deep brown noise for anxiety relief",
        tags: ["brown_noise", "deep", "calm"],
        popularity: 72
      },
      {
        id: "meditation_deep",
        title: "Deep Sleep Meditation",
        subtitle: "Guided sleep meditation",
        category: "Meditation",
        audioPath: "audio/meditation_deep.mp3",
        imagePath: "lib/assets/images/meditation.jpg",
        duration: 25,
        isLooping: false,
        isPremium: true,
        description: "Guided meditation for deep, restful sleep",
        tags: ["meditation", "guided", "sleep"],
        popularity: 85
      },
      {
        id: "body_scan",
        title: "Body Scan Relaxation",
        subtitle: "Progressive muscle relaxation",
        category: "Meditation",
        audioPath: "audio/body_scan.mp3",
        imagePath: "lib/assets/images/meditation.jpg",
        duration: 20,
        isLooping: false,
        isPremium: true,
        description: "Body scan meditation for tension release",
        tags: ["body_scan", "relaxation", "tension"],
        popularity: 79
      },
      {
        id: "delta_waves",
        title: "Delta Wave Binaural",
        subtitle: "0.5-4Hz brainwave entrainment",
        category: "Binaural Beats",
        audioPath: "audio/delta_waves.mp3",
        imagePath: "lib/assets/images/binaural.jpg",
        duration: 60,
        isLooping: true,
        isPremium: true,
        description: "Delta waves for deep sleep and healing",
        tags: ["binaural", "delta", "healing"],
        popularity: 68
      },
      {
        id: "theta_waves",
        title: "Theta Wave Binaural",
        subtitle: "4-8Hz brainwave entrainment",
        category: "Binaural Beats",
        audioPath: "audio/theta_waves.mp3",
        imagePath: "lib/assets/images/binaural.jpg",
        duration: 45,
        isLooping: true,
        isPremium: true,
        description: "Theta waves for REM sleep and creativity",
        tags: ["binaural", "theta", "rem"],
        popularity: 71
      },
      {
        id: "soft_piano",
        title: "Soft Piano",
        subtitle: "Gentle piano melodies",
        category: "Instrumental",
        audioPath: "audio/soft_piano.mp3",
        imagePath: "lib/assets/images/piano.jpg",
        duration: 35,
        isLooping: true,
        isPremium: false,
        description: "Peaceful piano music for relaxation",
        tags: ["piano", "instrumental", "peaceful"],
        popularity: 82
      },
      {
        id: "acoustic_guitar",
        title: "Acoustic Guitar",
        subtitle: "Soothing guitar melodies",
        category: "Instrumental",
        audioPath: "audio/acoustic_guitar.mp3",
        imagePath: "lib/assets/images/guitar.jpg",
        duration: 30,
        isLooping: true,
        isPremium: false,
        description: "Calming acoustic guitar for sleep",
        tags: ["guitar", "instrumental", "calming"],
        popularity: 77
      },
      {
        id: "space_ambient",
        title: "Space Ambient",
        subtitle: "Ethereal cosmic sounds",
        category: "Ambient",
        audioPath: "audio/space_ambient.mp3",
        imagePath: "lib/assets/images/space.jpg",
        duration: 50,
        isLooping: true,
        isPremium: false,
        description: "Journey through space with ambient sounds",
        tags: ["space", "ambient", "ethereal"],
        popularity: 65
      },
      {
        id: "dream_pad",
        title: "Dream Pad",
        subtitle: "Dreamy synthesizer pad",
        category: "Ambient",
        audioPath: "audio/dream_pad.mp3",
        imagePath: "lib/assets/images/dreams.jpg",
        duration: 40,
        isLooping: true,
        isPremium: false,
        description: "Dreamy ambient sounds for lucid dreaming",
        tags: ["dreams", "ambient", "synthesizer"],
        popularity: 70
      }
    ];
    
    // Insert default sounds
    const insertedSounds = await SleepSound.insertMany(defaultSounds);
    
    res.status(201).json({
      success: true,
      message: 'Default sounds initialized successfully',
      count: insertedSounds.length,
      data: insertedSounds
    });
  } catch (error) {
    console.error('Error initializing default sounds:', error);
    res.status(500).json({
      success: false,
      message: 'Error initializing default sounds',
      error: error.message
    });
  }
};