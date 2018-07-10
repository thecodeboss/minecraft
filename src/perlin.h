#pragma once

void initialize_random(unsigned seed);

double octave_perlin(double x, double y, double z, int octaves,
                     double persistence);

int xorhash(int value);
