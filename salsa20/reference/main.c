#include "ecrypt-sync.h"
#include "ecrypt-sync.h"
#include "salsa20.c"
#include <stdio.h>

int main() {
  /* Variable section start */
  u32 i;
  u32 bytes = 64;
  u8 stream[bytes];
  u8 m[bytes];
  u8 c[bytes];
  u8 d[bytes];

  u8 k[32];
  u8 v[8];

  ECRYPT_ctx x;

  u32 start_val = 8888;

  /* Variable section end */

  for (i = 0;i < bytes;++i) m[i] = 88;

  ECRYPT_keysetup(&x, k, 256, 64);
  ECRYPT_ivsetup(&x, v);

  printf("...post-setup input...\n");

  for (i = 0; i < 16; i++) {
    printf("0x%08x\n", x.input[i]);
  }
  
  printf("...m...\n");

  for (i = 0; i < bytes; i += 4) {
    printf("0x%02x%02x%02x%02x\n", m[i+3], m[i+2], m[i+1], m[i]);
  }

  printf("...ENCRYPTING...\n");

  ECRYPT_encrypt_bytes(&x, m, c, bytes);

  printf("...c...\n");

  for (i = 0; i < bytes; i += 4) {
    printf("0x%02x%02x%02x%02x\n", c[i+3], c[i+2], c[i+1], c[i]);
  }

  printf("...DECRYPTING...\n");

  ECRYPT_ivsetup(&x, v);
  ECRYPT_decrypt_bytes(&x, c, d, bytes);

  printf("...d...\n");

  for (i = 0; i < bytes; i += 4) {
    printf("0x%02x%02x%02x%02x\n", d[i+3], d[i+2], d[i+1], d[i]);
  }

  printf("...done\n");

  return 0;
}
