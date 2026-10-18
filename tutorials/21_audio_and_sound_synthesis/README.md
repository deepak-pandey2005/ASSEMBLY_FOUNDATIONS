# Module 21: Audio & Sound Synthesis — Generating Raw PCM Waveforms

## 🎯 Objectives
- Understand digital audio at the byte level:
  - Pulse-Code Modulation (PCM).
  - Sampling Rate (e.g., $44,100\text{ Hz}$ or $8,000\text{ Hz}$).
  - Sample Bit Depth (8-bit unsigned vs 16-bit signed).
- Understand mathematical wave generation without audio engines:
  - **Square wave**: Bitwise sign toggling.
  - **Sawtooth wave**: Linear phase accumulator with modulo rollover.
- Build an authentic RIFF/WAVE (`.wav`) header from raw binary bytes.
- Generate a playable `.wav` audio file entirely in 64-bit assembly!

---

## 1. Anatomy of a Canonical 44-Byte RIFF/WAVE Header

A `.wav` audio file is simply a 44-byte binary descriptor preceding raw PCM audio bytes:

```text
Offset  Size  Field          Value for 8kHz 8-bit Mono
0x00    4     ChunkID        "RIFF" (0x46464952)
0x04    4     ChunkSize      TotalFileSize - 8
0x08    4     Format         "WAVE" (0x45564157)
0x0C    4     Subchunk1ID    "fmt " (0x20746D66)
0x10    4     Subchunk1Size  16 (PCM)
0x14    2     AudioFormat    1 (Linear PCM)
0x16    2     NumChannels    1 (Mono)
0x18    4     SampleRate     8000
0x1C    4     ByteRate       8000 (SampleRate * NumChannels * BitsPerSample/8)
0x20    2     BlockAlign     1 (NumChannels * BitsPerSample/8)
0x22    2     BitsPerSample  8
0x24    4     Subchunk2ID    "data" (0x61746164)
0x28    4     Subchunk2Size  NumSamples * NumChannels * BitsPerSample/8
```

---

## 2. Hands-on Code Files in this Module
- [`synth_audio.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/21_audio_and_sound_synthesis/synth_audio.asm) - Generates a 2-second synthesized audio `.wav` file (`sound.wav`).
