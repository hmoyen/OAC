#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>

#define FILTER_EXP 0x7F800000
#define FILTER_SIGN 0x80000000
#define FILTER_FRACT 0x7FFFFF
#define FILTER_32 0xFFFFFF

typedef int32_t mint;
typedef uint32_t mfloat;

mfloat floatsisf(mint i);
mint fixsfsi(mfloat a);
mfloat negsf2(mfloat a);
mfloat addsf3(mfloat a, mfloat b);
mfloat subsf3(mfloat a, mfloat b);
void printBinary(int num);
