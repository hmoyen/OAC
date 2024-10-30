#include "float_lib.h"
#define FILTER_EXP 0x7F800000
#define FILTER_SIGN 0x80000000
#define FILTER_FRACT 0x7FFFFF
#define FILTER_32 0xFFFFFF

void printBinary(int num)
{
    // O tamanho em bits de um inteiro
    int bits = sizeof(num) * 8;

    for (int i = bits - 1; i >= 0; i--)
    {
        // Cria um bit a partir da posição atual
        int bit = (num >> i) & 1;
        printf("%d", bit);
    }
    printf("\n");
}

mfloat floatsisf(mint i)
{
    mint sign = 0;
    mint exp = 31; // indo da posiscao [31] do vetor
    mint fract;
    mint i_local = i;
    if (i == (mint)0)
    {
        return (mfloat)0;
    }
    if (i < 0)
    {
        sign = 1;
        i_local = -i;
    }
    while ((i_local & (1 << 31)) != (1 << 31)) // a partir do primeiro bit do numero, (i[31]), vai shiftando o numero ate que encontre-se o MSB == 1
    {
        i_local <<= 1;
        exp--; // enquanto nao for achado a casa do maior 1, o expoente vai diminuindo
    }

    fract = (i_local >> 8) & FILTER_FRACT;
    exp += 127;
    return (sign << 31) | (exp << 23) | fract;
}

mint fixsfsi(mfloat a)
{
    if (a == (mfloat)0)
        return (mint)0;
    mint r = a;
    mint exp = (a & FILTER_EXP) >> 23;
    exp -= 127;
    r &= FILTER_FRACT;
    r += (1 << 23);
    if (exp < 23)
        r >>= 23 - exp;
    else
        r <<= exp - 23;
    if ((a & FILTER_SIGN) != 0)
        r *= -1;
    return r;
}

mfloat negsf2(mfloat a)
{
    mfloat neg = a ^ FILTER_SIGN;

    return neg;
}

mfloat addsf3(mfloat a, mfloat b)
{
    if ((b == (mfloat)0))
        return a;
    if ((a == (mfloat)0))
        return b;

    mint exp_a = (a & FILTER_EXP) >> 23;
    mint exp_b = (b & FILTER_EXP) >> 23;
    mint fract_a = (a & FILTER_FRACT) + (1 << 23);
    mint fract_b = (b & FILTER_FRACT) + (1 << 23);
    mint sign_a = (a & FILTER_SIGN) >> 31;
    mint sign_b = (b & FILTER_SIGN) >> 31;
    mint fract, exp, sign;

    if (exp_a > exp_b)
    {
        fract_b >>= (exp_a - exp_b);
        exp = exp_a;
        sign = sign_a;
        if (sign_a == sign_b)
        {
            fract = fract_a + fract_b;
            while ((fract & (1 << 24)) == (1 << 24))
            {
                exp++;
                fract >>= 1;
            }
            fract = fract & FILTER_FRACT;
        }
        else
        {
            fract = fract_a - fract_b;

            while ((fract & (1 << 23)) != (1 << 23))
            {
                exp--;
                fract <<= 1;
            }
            fract = fract & FILTER_FRACT;
        }
    }

    else if (exp_a < exp_b)
    {
        fract_a >>= (exp_b - exp_a);
        exp = exp_b;
        sign = sign_b;
        if (sign_a == sign_b)
        {
            fract = fract_a + fract_b;
            while ((fract & (1 << 24)) == (1 << 24))
            {
                exp++;
                fract >>= 1;
            }
            fract = fract & FILTER_FRACT;
        }
        else
        {
            fract = fract_b - fract_a;

            while ((fract & (1 << 23)) != (1 << 23))
            {
                exp--;
                fract <<= 1;
            }
            fract = fract & FILTER_FRACT;
        }
    }
    else
    {
        exp = exp_b;
        sign = sign_b;
        if (sign_a == sign_b)
        {
            fract = fract_a + fract_b;
            while ((fract & (1 << 24)) == (1 << 24))
            {
                exp++;
                fract >>= 1;
            }
            fract = fract & FILTER_FRACT;
        }
        else
        {
            if (fract_b > fract_a)
            {
                fract = fract_b - fract_a;
            }
            else if (fract_b < fract_a)
            {
                fract = fract_a - fract_b;
            }
            else
            {
                return 0;
            }

            while ((fract & (1 << 23)) != (1 << 23))
            {
                exp--;
                fract <<= 1;
            }
            fract = fract & FILTER_FRACT;
        }
    }

    return (sign << 31) | (exp << 23) | fract;
}

mfloat subsf3(mfloat a, mfloat b)
{

    return addsf3(a, negsf2(b));
}
