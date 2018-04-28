#include "ecrypt-sync.h"
#include "c_salsa20.c"
#include <stdio.h>

int main() {
  u32 input[16];
  u8 output[64];
  int i;

  u32 start_val = 8888;

  for (i = 0; i < 16; i++) {
    input[i] = start_val;
  }

  printf("input...\n");

  for (i = 0; i < 16; i++) {
    printf("0x%08x\n", input[i]);
  }

  printf("...encrypting...\n");

  c_salsa20_wordtobyte(output, input);

  for (i = 0; i < 64; i += 4) {
    printf("0x%02x%02x%02x%02x\n", output[i+3], output[i+2], output[i+1], output[i]);
  }

  printf("...done\n");

  return 0;
}
