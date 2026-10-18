# Module 12: Graphics & Framebuffer — Direct Pixel Rendering

## 🎯 Objectives
- Understand how display hardware and GPUs work at the lowest software boundary:
  - Video memory (VRAM) mapping.
  - Linear Framebuffers: each pixel is a word in memory ($X, Y \to \text{Offset}$).
  - Color models: 24-bit RGB and 32-bit ARGB/XRGB.
- Learn the Framebuffer Coordinate Calculation formula:
  $$\text{Pixel Offset} = (Y \times \text{Width} + X) \times \text{BytesPerPixel}$$
- Generate uncompressed Netpbm Portable Pixmap (PPM) graphics directly from assembly, creating geometric patterns, gradients, and shapes viewable on any system or web browser!

---

## 1. How Graphics Hardware Renders Pixels

At the physical hardware level:
1. The graphics card maps its display RAM into the CPU's memory address space (via PCI BARs / `/dev/fb0` on Linux or VESA BIOS Extensions in bare-metal).
2. Changing colors on the screen is literally just a series of `mov [pointer], color` instructions!

For a 24-bit RGB or 32-bit XRGB display:
```text
Byte 0: Blue   (0x00 - 0xFF)
Byte 1: Green  (0x00 - 0xFF)
Byte 2: Red    (0x00 - 0xFF)
Byte 3: Alpha  (optional)
```

---

## 2. Portable Pixmap (PPM) Binary Format

The PPM format (P6) is the rawest image format in computer science:
1. **Header (ASCII text)**:
   ```text
   P6
   <width> <height>
   255
   ```
2. **Body (Binary bytes)**:
   Direct sequence of $3 \times \text{Width} \times \text{Height}$ bytes containing raw Red, Green, and Blue values.

---

## 3. Hands-on Code Files in this Module
- [`render_pattern.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/12_framebuffer_and_graphics/render_pattern.asm) - Pure assembly 2D graphics renderer that generates a 256x256 color palette image `canvas.ppm`.
