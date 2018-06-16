#include <stdint.h>
#include <stdio.h>

void tea_encrypt(uint32_t v[2], uint32_t k[4]) {
    uint32_t v0=v[0], v1=v[1], sum=0, i;           /* set up */
    uint32_t delta=0x9e3779b9;                     /* a key schedule constant */
    uint32_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
    for (i=0; i < 32; i++) {                       /* basic cycle start */
        sum += delta;
        v0 += ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        v1 += ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
    }                                              /* end cycle */
    v[0]=v0; v[1]=v1;
}

void tea_decrypt(uint32_t v[2], uint32_t k[4]) {
    uint32_t v0=v[0], v1=v[1], sum=0xC6EF3720, i;  /* set up */
    uint32_t delta=0x9e3779b9;                     /* a key schedule constant */
    uint32_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
    for (i=0; i<32; i++) {                         /* basic cycle start */
        v1 -= ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
        v0 -= ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        sum -= delta;
    }                                              /* end cycle */
    v[0]=v0; v[1]=v1;
}

uint32_t wtf(uint32_t j) {
  for(uint32_t i = 0; i <32; i++) {
    j++;
  }
  return j;
}

int main() {
  uint32_t message[2] = { 0xdeadbeef, 0xbeeff00d };
  uint32_t key[4]     = { 0xd34db33f, 0xb33ff33d, 0xf000ba12, 0xdeadf00d };
  tea_encrypt(message, key);
  printf("%d\n%d\n", message[0], message[1]);
  tea_decrypt(message, key);
  printf("Okay: %d?\n", message[0] == 0xdeadbeef &&
                        message[1] == 0xbeeff00d);
  return 0;
}
