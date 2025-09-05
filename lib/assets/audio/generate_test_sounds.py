#!/usr/bin/env python3
"""
Simple script to generate test audio files for the sleep app.
This creates basic sine wave tones that can be used as placeholders.
"""

import numpy as np
import wave
import os

def create_tone_file(filename, frequency, duration, sample_rate=44100):
    """Create a simple sine wave tone and save as WAV file"""
    t = np.linspace(0, duration, int(sample_rate * duration), False)
    
    # Generate sine wave
    wave_data = np.sin(2 * np.pi * frequency * t)
    
    # Apply fade in/out to avoid clicks
    fade_duration = 0.1  # 100ms fade
    fade_samples = int(sample_rate * fade_duration)
    
    # Fade in
    wave_data[:fade_samples] *= np.linspace(0, 1, fade_samples)
    # Fade out
    wave_data[-fade_samples:] *= np.linspace(1, 0, fade_samples)
    
    # Scale to 16-bit range
    wave_data = (wave_data * 32767).astype(np.int16)
    
    # Save as WAV file
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(wave_data.tobytes())
    
    print(f"Created {filename} - {frequency}Hz for {duration}s")

def create_white_noise_file(filename, duration, sample_rate=44100):
    """Create white noise and save as WAV file"""
    samples = int(sample_rate * duration)
    
    # Generate white noise
    wave_data = np.random.normal(0, 0.1, samples)
    
    # Apply fade in/out
    fade_duration = 0.1
    fade_samples = int(sample_rate * fade_duration)
    
    wave_data[:fade_samples] *= np.linspace(0, 1, fade_samples)
    wave_data[-fade_samples:] *= np.linspace(1, 0, fade_samples)
    
    # Scale to 16-bit range
    wave_data = (wave_data * 32767).astype(np.int16)
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(wave_data.tobytes())
    
    print(f"Created {filename} - White noise for {duration}s")

def main():
    """Generate test audio files"""
    print("Generating test audio files for sleep app...")
    
    # Create directory if it doesn't exist
    os.makedirs('.', exist_ok=True)
    
    # Generate different test sounds (short duration for testing)
    duration = 5  # 5 seconds each for testing
    
    # Nature sounds (using different frequencies to simulate different sounds)
    create_tone_file('rain_heavy.wav', 200, duration)  # Low rumble for rain
    create_tone_file('rain_light.wav', 400, duration)  # Higher for light rain
    create_tone_file('ocean_waves.wav', 100, duration)  # Very low for ocean
    create_tone_file('forest_ambient.wav', 800, duration)  # Mid-range for forest
    
    # White noise variants
    create_white_noise_file('white_noise.wav', duration)
    create_white_noise_file('pink_noise.wav', duration)
    create_white_noise_file('brown_noise.wav', duration)
    
    # Meditation (softer tones)
    create_tone_file('meditation_deep.wav', 220, duration)  # A3 note
    create_tone_file('body_scan.wav', 174, duration)  # Lower meditation frequency
    
    # Binaural (specific frequencies)
    create_tone_file('delta_waves.wav', 2, duration)  # Very low delta frequency
    create_tone_file('theta_waves.wav', 6, duration)  # Theta frequency
    
    # Instrumental (musical notes)
    create_tone_file('soft_piano.wav', 440, duration)  # A4 note
    create_tone_file('acoustic_guitar.wav', 330, duration)  # E4 note
    
    # Ambient
    create_tone_file('space_ambient.wav', 55, duration)  # Very low ambient
    create_tone_file('dream_pad.wav', 110, duration)  # Low dreamy tone
    
    print(f"\nGenerated {15} test audio files!")
    print("Note: These are simple test tones. Replace with real audio files for production.")

if __name__ == "__main__":
    try:
        main()
    except ImportError:
        print("Error: numpy is required to generate audio files")
        print("Install with: pip install numpy")
    except Exception as e:
        print(f"Error generating audio files: {e}")