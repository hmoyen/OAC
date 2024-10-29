#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
typedef int32_t mint;
typedef uint32_t mfloat;

mint *convert_I2B(mint i);
mfloat floatsisf(mint i);
mint convert_B2I(mint *b, int size);
mint power(a, int i);
void print_32bit_array(mint *b);
mfloat convert_B2F(mint *r, int size);
mint *convert_F2B(mfloat f);
mint fixsfsi(mfloat a);

int main()
{

    return 0;
}

mint *convert_I2B(mint i) // bit-sign convertion
{
    static mint b[32];
    mint temp_i;
    if (i < 0)
    {
        temp_i = -i;
        b[31] = 1;
    }
    else
    {
        temp_i = i;
        b[31] = 0;
    }

    for (int j = 0; j < 31; j++)
    {
        b[j] = 0;
    }
    for (int j = 0; j < 31; j++)
    {
        b[j] = temp_i % 2;
        temp_i = temp_i / 2;
    }
    return b;
}

mint *convert_F2B(mfloat f)
{
    static mint p[32];
    mfloat temp_f = f;
    if (f >> 31 == 0)
        p[31] = 0;

    else
        p[31] = 1;

    for (int j = 0; j < 31; j++)
        p[j] = 0;
    for (int j = 0; j < 31; j++)
    {
        p[j] = temp_f % 2;
        temp_f = temp_f / 2;
    }
    return p;
}

mint convert_B2I(mint *b, int size)
{
    mint r = 0;
    for (int i = 0; i <= size; i++)
    {
        r += b[i] * power(2, i);
    }
    return r;
}

mfloat convert_B2F(mint *r, int size)
{
    mfloat f = 0;
    for (int i = 0; i <= size; i++)
    {
        f += r[i] * power(2, i);
    }
    return f;
}

mfloat floatsisf(mint i)
{
    if (i == 0)
        return 0;
    mint *r = (mint *)calloc(32, sizeof(mint));
    mint *b = convert_I2B(i); // find binary for easier convertion
    r[31] = b[31];
    int exp = 127;
    int fract = 0;
    int j;

    for (j = 30; j >= 0; j--)
    {
        if (b[j] != 0) // first non-zero bit for rounding
            break;
    }

    exp += j;
    b[j] = 0; // remove the first 1
    fract = convert_B2I(b, j);
    if (j > 23)
    {
        fract = fract >> (j - 23);
    }
    else
    {
        fract = fract << (23 - j);
    }
    b = convert_I2B(fract);
    for (j = 0; j < 23; j++)
    {
        r[j] = b[j];
    }
    b = convert_I2B(exp);
    for (j = 23; j < 31; j++)
    {
        r[j] = b[j - 23];
    }
    mfloat f = convert_B2F(r, 32);
    free(r);
    return f;
}

mint power(int a, int i)
{
    int r = 1;
    for (int j = 0; j < i; j++)
    {
        r *= a;
    }
    if (i < 0)
    {
        return 1 / r;
    }
    return r;
}

void print_32bit_array(mint *b)
{

    printf("\n");
    for (int j = 31; j >= 0; j--)
    {
        printf("%d", b[j]);
    }
    printf("\n");
    return;
}

mint fixsfsi(mfloat a)
{
    mint *r = convert_F2B(a);
    mint fract_a[24];
    mint exp_a[8];
    mint p;

    int j;
    for (j = 0; j < 23; j++)
        fract_a[j] = r[j];
    fract_a[23] = 1;

    for (; j < 30; j++)
        exp_a[j - 23] = r[j];
    mint exp = convert_B2I(exp_a, 8);
    if (exp < 127)
        return 0;
    exp -= 127;

    for (j = 0; j < exp; j++)
    {
        p += (power(-1, r[31])) * fract_a[j] * power(2, j);
    }
}
