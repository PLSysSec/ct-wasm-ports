#include <stdio.h>
#include <memory.h>
#include <string.h>
#include "sha256.h"

#define INIT_TESTS()                                                           \
    unsigned int passed = 0, failed = 0, set = 0, vec = 0;                     \
    SHA256_CTX ctx;

#define SET()                                                                  \
    set++;                                                                     \
    vec = 0;

#define TEST(in, out)                                                          \
    vec++;                                                                     \
    if (sha256_test(&ctx, in, (BYTE[SHA256_BLOCK_SIZE])out)) {                 \
        fprintf(stderr, "Set % 3d, vector % 3d: PASSED\n", set, vec);          \
        passed++;                                                              \
    } else {                                                                   \
        fprintf(stderr, "Set % 3d, vector % 3d: FAILED\n", set, vec);          \
        failed++;                                                              \
    }

#define HASH(...) __VA_ARGS__

#define TEST_RESULTS()                                                         \
    fprintf(stderr, "\n");                                                     \
    fprintf(stderr, "Tests passed: %d\n", passed);                             \
    fprintf(stderr, "Tests failed: %d\n", failed);                             \
    fprintf(stderr, "Total tests executed: %d\n", passed + failed);

int sha256_test (SHA256_CTX * ctx, BYTE * in, BYTE out[SHA256_BLOCK_SIZE]) {
    BYTE buf[SHA256_BLOCK_SIZE];
    sha256_init(ctx);
    sha256_update(ctx, in, strlen(in));
    sha256_final(ctx, buf);
    return !memcmp(out, buf, SHA256_BLOCK_SIZE);
}

int main (int argc, char * argv[]) {
    INIT_TESTS();

    SET();
    TEST("", HASH({0xE3, 0xB0, 0xC4, 0x42, 0x98, 0xFC, 0x1C, 0x14, 0x9A, 0xFB, 0xF4, 0xC8, 0x99, 0x6F, 0xB9, 0x24, 0x27, 0xAE, 0x41, 0xE4, 0x64, 0x9B, 0x93, 0x4C, 0xA4, 0x95, 0x99, 0x1B, 0x78, 0x52, 0xB8, 0x55}));

    TEST_RESULTS();
}
