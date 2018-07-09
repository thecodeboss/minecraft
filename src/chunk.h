#pragma once
#include <inttypes.h>
#include <stdio.h>
#include "erl_nif.h"

#define MC_AIR 0ul
#define MC_STONE 16ul
#define MC_GRASS 32ul
#define MC_DIRT 48ul
#define MC_COBBLESTONE 64ul
#define MC_BEDROCK 112ul
#define MC_STILL_WATER 144ul
#define MC_SAND 192ul
#define MC_GRAVEL 208ul
#define MC_OAK_WOOD 272ul
#define MC_OAK_LEAVES 288ul

#define MC_TALL_GRASS 497ul
#define MC_DANDELION 592ul

struct Block {
  uint16_t type;
  uint8_t block_light;
  uint8_t sky_light;
};

struct ChunkSection {
  int32_t y;
  struct Block blocks[16 * 16 * 16];
};

struct Chunk {
  int32_t x;
  int32_t z;
  uint8_t *heightmap;
  uint8_t num_sections;
  struct ChunkSection *chunk_sections[16];
};

struct ChunkSection *generate_chunk_section(uint8_t *heightmap,
                                            int32_t chunk_y);

ERL_NIF_TERM serialize_chunk_section(ErlNifEnv *env,
                                     struct ChunkSection *chunk_section);