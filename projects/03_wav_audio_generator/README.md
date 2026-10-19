# Project 03: Polyphonic WAV Synthesizer (Pure x86-64 Assembly)

A standalone command-line audio synthesizer that generates complete, multi-tone RIFF/WAVE audio files from mathematical algorithms in pure assembly.

---

## 🎵 Features
- **44-Byte Standard RIFF/WAVE Header**:
  - Dynamically calculates file and subchunk sizes.
  - Linear PCM, $44.1\text{ kHz}$ sampling rate, 16-bit signed audio depth, stereo 2-channel sound.
- **Waveform Synthesis Engine**:
  - Dual-frequency chord generation (harmonizing tonic + fifth).
  - Exponential decay envelope ($ADSR$) to simulate piano/guitar string plucks.
  - Generates `output.wav` playable directly by `aplay`, `vlc`, or any browser/media player.

---

## 🛠️ Build and Run

```bash
# Build synthesizer
make

# Generate audio file
make run

# Clean artifacts
make clean
```
