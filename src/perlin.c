#include "perlin.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>

static int p[512];

void initialize_random(unsigned seed) {
  srand(seed);
  for (unsigned i = 0; i < 512; i++) {
    p[i] = rand() % 256;
  }
}

static double fade(double t) {
  return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

static double lerp(double a, double b, double x) { return a + x * (b - a); }

static double grad(int hash, double x, double y, double z) {
  switch (hash & 0xF) {
    case 0x0:
      return x + y;
    case 0x1:
      return -x + y;
    case 0x2:
      return x - y;
    case 0x3:
      return -x - y;
    case 0x4:
      return x + z;
    case 0x5:
      return -x + z;
    case 0x6:
      return x - z;
    case 0x7:
      return -x - z;
    case 0x8:
      return y + z;
    case 0x9:
      return -y + z;
    case 0xA:
      return y - z;
    case 0xB:
      return -y - z;
    case 0xC:
      return y + x;
    case 0xD:
      return -y + z;
    case 0xE:
      return y - x;
    case 0xF:
      return -y - z;
    default:
      return 0;  // never happens
  }
}

static int xorhash(int value) {
  return (value & 0xFF) ^ ((value >> 8) & 0xFF) ^ ((value >> 16) & 0xFF);
}

static double perlin(double x, double y, double z) {
  int floor_x = (int)floor(x);
  int floor_y = (int)floor(y);
  int floor_z = (int)floor(z);
  int xi = xorhash(floor_x);
  int xi1 = xorhash(floor_x + 1);
  int yi = xorhash(floor_y);
  int yi1 = xorhash(floor_y + 1);
  int zi = xorhash(floor_z);
  int zi1 = xorhash(floor_z + 1);
  double xf = x - floor_x;
  double yf = y - floor_y;
  double zf = z - floor_z;
  double u = fade(xf);
  double v = fade(yf);
  double w = fade(zf);
  int aaa = p[p[p[xi] + yi] + zi];
  int aba = p[p[p[xi] + yi1] + zi];
  int aab = p[p[p[xi] + yi] + zi1];
  int abb = p[p[p[xi] + yi1] + zi1];
  int baa = p[p[p[xi1] + yi] + zi];
  int bba = p[p[p[xi1] + yi1] + zi];
  int bab = p[p[p[xi1] + yi] + zi1];
  int bbb = p[p[p[xi1] + yi1] + zi1];
  double x1 = lerp(grad(aaa, xf, yf, zf), grad(baa, xf - 1.0, yf, zf), u);
  double x2 =
      lerp(grad(aba, xf, yf - 1.0, zf), grad(bba, xf - 1.0, yf - 1.0, zf), u);
  double y1 = lerp(x1, x2, v);

  x1 = lerp(grad(aab, xf, yf, zf - 1.0), grad(bab, xf - 1.0, yf, zf - 1.0), u);
  x2 = lerp(grad(abb, xf, yf - 1.0, zf - 1.0),
            grad(bbb, xf - 1.0, yf - 1.0, zf - 1.0), u);
  double y2 = lerp(x1, x2, v);

  return (lerp(y1, y2, w) + 1.0) / 2.0;
}

double octave_perlin(double x, double y, double z, int octaves,
                     double persistence) {
  double total = 0;
  double frequency = 0.02;
  double amplitude = 1;
  double maxValue = 0;  // Used for normalizing result to 0.0 - 1.0
  for (int i = 0; i < octaves; i++) {
    total += perlin(x * frequency, y * frequency, z * frequency) * amplitude;

    maxValue += amplitude;

    amplitude *= persistence;
    frequency *= 2;
  }

  return total / maxValue;
}
