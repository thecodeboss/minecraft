#include "biome.h"
#include <math.h>
#include "perlin.h"

extern int p[512];
extern int p2[512];

static double distance(double x1, double y1, double x2, double y2) {
  return sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
}

static const int chunks_per_zone = 40;

struct Zone {
  int x[10];
  int z[10];
  uint8_t biome[10];
  uint8_t count;
};

static void init_zone(int zone_x, int zone_z, struct Zone* zone) {
  zone->count = p[xorhash(zone_x ^ zone_z)] / 26;
  for (int i = 0; i < zone->count; i++) {
    zone->x[i] =
        p2[xorhash(p[i] ^ p[zone_x * zone_z])] % (chunks_per_zone * 16);
    zone->z[i] =
        p2[xorhash((i * 97 - 2) ^ (zone_x * 131 - 17) ^ (zone_z * 29 - 89))] %
        (chunks_per_zone * 16);
    zone->biome[i] =
        p2[xorhash((i * 29 - 5) ^ (zone_x * 239 - 177) ^ (zone_z * 61 - 91))] %
        B_NUM_BIOMES;
  }
}

uint8_t get_biome(double x, double z) {
  int zone_x = (int)floor(x / (16 * chunks_per_zone));
  int zone_z = (int)floor(z / (16 * chunks_per_zone));
  struct Zone zones[9];
  int count = 0;
  for (int i = zone_x - 1; i <= zone_x + 1; i++) {
    for (int j = zone_z - 1; j <= zone_z + 1; j++) {
      init_zone(i, j, &zones[count++]);
    }
  }

  uint8_t biome = 0;
  double min_distance = 10000000.0;
  count = 0;
  for (int i = zone_x - 1; i <= zone_x + 1; i++) {
    for (int j = zone_z - 1; j <= zone_z + 1; j++) {
      struct Zone zone = zones[count++];
      for (int k = 0; k < zone.count; k++) {
        double d = distance(x, z, zone.x[k] + i * chunks_per_zone * 16,
                            zone.z[k] + j * chunks_per_zone * 16);
        if (d < min_distance) {
          min_distance = d;
          biome = zone.biome[k];
        }
      }
    }
  }

  switch (biome) {
    case 0:
      biome = B_OCEAN;
      break;
    case 1:
      biome = B_PLAINS;
      break;
    case 2:
      biome = B_DESERT;
      break;
    case 3:
      biome = B_FOREST;
      break;
    case 4:
      biome = B_TAIGA;
      break;
    case 5:
      biome = B_SWAMP;
      break;
    case 6:
      biome = B_ICE_PLAINS;
      break;
    case 7:
      biome = B_JUNGLE;
      break;
    case 8:
      biome = B_BIRCH_FOREST;
      break;
    default:
      biome = B_PLAINS;
      break;
  }

  return biome;
}
