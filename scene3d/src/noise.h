#ifndef NOISE_H
#define NOISE_H

namespace Simplex
{
    void Seed(int x);
    float FractalNoise2(float x, float y, int octaves, float persistence, float lacunarity);
    float FractalNoise3(float x, float y, float z, int octaves, float persistence, float lacunarity);
    float FractalNoise4(float x, float y, float z, float w, int octaves, float persistence, float lacunarity);
} // namespace Simplex

#endif NOISE_H