#pragma once
#include <inttypes.h>
#include <stdio.h>
#include "erl_nif.h"

#define MC_GRASS 0x20ul

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