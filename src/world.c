#include <byteswap.h>
#include <inttypes.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "erl_nif.h"

#define MC_GRASS 0x20ul

static int p[512];

static void initialize_random(unsigned seed) {
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

static double perlin(double x, double y, double z) {
  int floor_x = (int)floor(x);
  int floor_y = (int)floor(y);
  int floor_z = (int)floor(z);
  int xi =
      (floor_x & 0xFF) ^ ((floor_x >> 8) & 0xFF) ^ ((floor_x >> 16) & 0xFF);
  int yi =
      (floor_y & 0xFF) ^ ((floor_y >> 8) & 0xFF) ^ ((floor_y >> 16) & 0xFF);
  int zi =
      (floor_z & 0xFF) ^ ((floor_z >> 8) & 0xFF) ^ ((floor_z >> 16) & 0xFF);
  double xf = x - floor_x;
  double yf = y - floor_y;
  double zf = z - floor_z;
  double u = fade(xf);
  double v = fade(yf);
  double w = fade(zf);
  int aaa = p[p[p[xi] + yi] + zi];
  int aba = p[p[p[xi] + yi + 1] + zi];
  int aab = p[p[p[xi] + yi] + zi + 1];
  int abb = p[p[p[xi] + yi + 1] + zi + 1];
  int baa = p[p[p[xi + 1] + yi] + zi];
  int bba = p[p[p[xi + 1] + yi + 1] + zi];
  int bab = p[p[p[xi + 1] + yi] + zi + 1];
  int bbb = p[p[p[xi + 1] + yi + 1] + zi + 1];
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

static double octave_perlin(double x, double y, double z, int octaves,
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

/*
 * NIF definitions.
 */

static ERL_NIF_TERM set_random_seed(ErlNifEnv *env, int argc,
                                    const ERL_NIF_TERM argv[]) {
  (void)argc;
  unsigned seed;

  enif_get_int(env, argv[0], (int *)&seed);
  initialize_random(seed);

  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM generate_chunk_section(ErlNifEnv *env, unsigned *heightmap,
                                           int chunk_y) {
  ERL_NIF_TERM chunk_section;
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
  uint8_t *raw =
      (uint8_t *)enif_make_new_binary(env, total_size_bytes, &chunk_section);

  // Fill the chunk with air
  memset((void *)raw, 0, total_size_bytes);

  *raw++ = bits_per_block;
  *raw++ = palette;

  uint16_t *raw16 = (uint16_t *)raw;
  *raw16++ = data_array_length_encoded;

  uint64_t *data = (uint64_t *)raw16;

  for (uint32_t y = 0; y < 16; y++) {
    unsigned block_y = chunk_y * 16 + y;
    for (uint32_t z = 0; z < 16; z++) {
      for (uint32_t x = 0; x < 16; x++) {
        size_t block_number = (((y * 16) + z) * 16) + x;
        size_t start_long = (block_number * bits_per_block) / 64;
        size_t start_offset = (block_number * bits_per_block) % 64;
        size_t end_long = ((block_number + 1) * bits_per_block - 1) / 64;

        uint64_t value = (block_y <= heightmap[z * 16 + x]) ? MC_GRASS : 0;
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
        *raw++ = 0;
      }
    }
  }

  // Sky Light
  for (uint32_t y = 0; y < 16; y++) {
    for (uint32_t z = 0; z < 16; z++) {
      for (uint32_t x = 0; x < 16; x += 2) {
        *raw++ = 0xFF;
      }
    }
  }

  return chunk_section;
}

/*
 * Returns a list of chunk sections.
 */
static ERL_NIF_TERM generate_chunk(ErlNifEnv *env, int argc,
                                   const ERL_NIF_TERM argv[]) {
  (void)argc;
  int chunk_x, chunk_z;

  enif_get_int(env, argv[0], (int *)&chunk_x);
  enif_get_int(env, argv[1], (int *)&chunk_z);

  double start_x = chunk_x * 16.0;
  double start_z = chunk_z * 16.0;

  // First generate a surface level heightmap for the chunk
  unsigned *heightmap = (unsigned *)enif_alloc(sizeof(unsigned) * 16 * 16);
  unsigned max_height = 0;
  double x = start_x;
  double z = start_z;
  for (size_t i = 0; i < 16; z++, i++) {
    x = start_x;
    for (size_t j = 0; j < 16; x++, j++) {
      unsigned h = 100 * octave_perlin(x + 8888888.483, 28.237, z + 8888888.483,
                                       1, 0.4) +
                   32;
      if (h > 255) h = 255;
      if (h > max_height) max_height = h;
      heightmap[i * 16 + j] = h;
    }
  }

  // Figure out how many chunk sections we need to output
  int num_chunk_sections = (int)ceil((max_height + 1) / 16.0);
  ERL_NIF_TERM chunk_sections[16];

  for (int i = 0; i < num_chunk_sections; i++) {
    chunk_sections[i] = generate_chunk_section(env, heightmap, i);
  }

  ERL_NIF_TERM chunk =
      enif_make_list_from_array(env, chunk_sections, num_chunk_sections);

  // Free allocated resources
  enif_free((void *)heightmap);

  // Final result
  return enif_make_tuple2(env, enif_make_atom(env, "ok"), chunk);
}

static ErlNifFunc nif_funcs[] = {
    // {erl_function_name, erl_function_arity, c_function, flags}
    {"set_random_seed", 1, set_random_seed, 0},
    {"generate_chunk", 2, generate_chunk, 0}};

ERL_NIF_INIT(Elixir.Minecraft.World.NIF, nif_funcs, NULL, NULL, NULL, NULL)
