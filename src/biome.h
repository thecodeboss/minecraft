#pragma once
#include <inttypes.h>

#define B_OCEAN 0
#define B_PLAINS 1
#define B_DESERT 2
#define B_FOREST 4
#define B_TAIGA 5
#define B_SWAMP 6
#define B_ICE_PLAINS 12
#define B_JUNGLE 21
#define B_BIRCH_FOREST 27

#define B_NUM_BIOMES 9

uint8_t get_biome(double x, double z);
