#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <memory.h>
#include <string.h>

int sha256(const uint8_t *src, uint32_t len, uint32_t *hash);