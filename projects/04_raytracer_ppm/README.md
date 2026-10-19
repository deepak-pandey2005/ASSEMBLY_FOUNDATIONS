# Project 04: 3D Sphere Raytracer (Pure x86-64 Assembly)

A 3D mathematical raytracer written entirely in x86-64 assembly that casts primary rays from a virtual camera, tests ray-sphere intersection quadratic equations, and applies Lambertian diffuse surface shading with light vectors.

---

## 🎨 Graphics & Math Architecture
- **Camera Model**:
  - Virtual pinhole camera at $(0, 0, -2)$ looking along $+Z$.
  - Viewplane mapping pixel coordinates $(X, Y)$ into normalized world ray directions $(R_x, R_y, R_z)$.
- **Ray-Sphere Intersection**:
  - Solves the quadratic equation:
    $$\| \mathbf{P} - \mathbf{C} \|^2 = r^2$$
    $$\mathbf{D} \cdot \mathbf{D} \, t^2 + 2 (\mathbf{O} - \mathbf{C}) \cdot \mathbf{D} \, t + (\mathbf{O} - \mathbf{C}) \cdot (\mathbf{O} - \mathbf{C}) - r^2 = 0$$
- **Lambertian Diffuse Shading**:
  - Computes the surface normal vector $\mathbf{N} = \frac{\mathbf{P} - \mathbf{C}}{\|\mathbf{P} - \mathbf{C}\|}$.
  - Shading brightness is proportional to the dot product of normal and light direction:
    $$I = \max(0, \, \mathbf{N} \cdot \mathbf{L})$$
- **Output Format**:
  - Uncompressed 24-bit RGB Portable Pixmap (`render.ppm`).

---

## 🛠️ Build and Run

```bash
# Build raytracer
make

# Render image
make run

# Clean output
make clean
```
