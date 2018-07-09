#include "chunk.h"
#include <byteswap.h>
#include <string.h>

struct ChunkSection *generate_chunk_section(uint8_t *heightmap,
                                            int32_t chunk_y) {
  struct ChunkSection *chunk_section = enif_alloc(sizeof(struct ChunkSection));
  chunk_section->y = chunk_y;
  for (uint32_t y = 0; y < 16; y++) {
    unsigned block_y = chunk_y * 16 + y;
    for (uint32_t z = 0; z < 16; z++) {
      for (uint32_t x = 0; x < 16; x++) {
        size_t block_number = (((y * 16) + z) * 16) + x;
        chunk_section->blocks[block_number].type =
            (block_y <= heightmap[z * 16 + x]) ? MC_GRASS : 0;
        chunk_section->blocks[block_number].block_light = 0;
        chunk_section->blocks[block_number].sky_light = 0xF;
      }
    }
  }

  return chunk_section;
}

ERL_NIF_TERM serialize_chunk_section(ErlNifEnv *env,
                                     struct ChunkSection *chunk_section) {
  ERL_NIF_TERM chunk_section_term;
  const uint8_t bits_per_block = 13;
  const uint64_t value_mask = (1UL << bits_per_block) - 1;
  const uint8_t palette = 0;
  const uint16_t data_array_length = 16 * 16 * 16 * bits_per_block / 64;
  const uint16_t data_array_length_encoded = bswap_16(0xC006);
  const size_t total_size_bytes =
      sizeof(uint8_t)                         // bits_per_block
      + sizeof(uint8_t)                       // palette
      + sizeof(uint16_t)                      // data_array_length
      + sizeof(uint64_t) * data_array_length  // data
      + sizeof(uint8_t) * (16 * 16 * 16);     // block light and sky light
  uint8_t *raw = (uint8_t *)enif_make_new_binary(env, total_size_bytes,
                                                 &chunk_section_term);

  // Fill the chunk with air
  memset((void *)raw, 0, total_size_bytes);

  *raw++ = bits_per_block;
  *raw++ = palette;

  uint16_t *raw16 = (uint16_t *)raw;
  *raw16++ = data_array_length_encoded;

  uint64_t *data = (uint64_t *)raw16;

  for (uint32_t y = 0; y < 16; y++) {
    for (uint32_t z = 0; z < 16; z++) {
      for (uint32_t x = 0; x < 16; x++) {
        size_t block_number = (((y * 16) + z) * 16) + x;
        size_t start_long = (block_number * bits_per_block) / 64;
        size_t start_offset = (block_number * bits_per_block) % 64;
        size_t end_long = ((block_number + 1) * bits_per_block - 1) / 64;

        uint64_t value = chunk_section->blocks[block_number].type;
        value &= value_mask;

        data[start_long] |= (value << start_offset);

        if (start_long != end_long) {
          data[end_long] = (value >> (64 - start_offset));
        }
      }
    }
  }

  for (uint16_t i = 0; i < data_array_length; i++) {
    data[i] = bswap_64(data[i]);
  }

  raw = (uint8_t *)(data + data_array_length);

  // Block Light
  for (uint32_t y = 0; y < 16; y++) {
    for (uint32_t z = 0; z < 16; z++) {
      for (uint32_t x = 0; x < 16; x += 2) {
        size_t block_number = (((y * 16) + z) * 16) + x;
        uint8_t light1 = chunk_section->blocks[block_number].block_light;
        uint8_t light2 = chunk_section->blocks[block_number + 1].block_light;
        *raw++ = light1 | (light2 << 4);
      }
    }
  }

  // Sky Light
  for (uint32_t y = 0; y < 16; y++) {
    for (uint32_t z = 0; z < 16; z++) {
      for (uint32_t x = 0; x < 16; x += 2) {
        size_t block_number = (((y * 16) + z) * 16) + x;
        uint8_t light1 = chunk_section->blocks[block_number].sky_light;
        uint8_t light2 = chunk_section->blocks[block_number + 1].sky_light;
        *raw++ = light1 | (light2 << 4);
      }
    }
  }

  return chunk_section_term;
}
