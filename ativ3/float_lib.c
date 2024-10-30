/*
float_lib: Atividade 3 de OAC

Caio Escorcio Lima Dourado - 13680313
30/10/2024


 */

#include "float_lib.h"
#define FILTER_EXP 0x7F800000
#define FILTER_SIGN 0x80000000
#define FILTER_FRACT 0x7FFFFF

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
    mint exp = (a & FILTER_EXP) >> 23; // acha o expoente
    r &= FILTER_FRACT;
    r |= (1 << 23);
    exp -= 127;
    if (exp < 0)
        return 0;
    if (exp >= 23)
    {
        r <<= (exp - 23);
    }
    else
    {
        r >>= (23 - exp); // faz o shift para a mantissa ficar com 23 bits
    }
    if ((a & FILTER_SIGN) != 0)
        r *= -1;
    return r;
}

mfloat negsf2(mfloat a)
{
    mfloat neg = a ^ FILTER_SIGN; // bit-shift

    return neg;
}

mfloat addsf3(mfloat a, mfloat b)
{
    if ((b == 0x00000000))
        return a;
    if ((a == 0x00000000))
        return b;

    // filtra os dados de cada um dos operandos para analisar quais os expoentes, fracoes e sinais
    mfloat exp_a = (a & FILTER_EXP) >> 23;
    mfloat exp_b = (b & FILTER_EXP) >> 23;
    mfloat fract_a = (a & FILTER_FRACT) | (1 << 23);
    mfloat fract_b = (b & FILTER_FRACT) | (1 << 23);
    mfloat sign_a = (a & FILTER_SIGN) >> 31;
    mfloat sign_b = (b & FILTER_SIGN) >> 31;
    mfloat fract, exp, sign;

    if (exp_a >= exp_b) // acha qual sinal eh maior
    {
        fract_b = (exp_a - exp_b) < 32 ? fract_b >> (exp_a - exp_b) : 0; // evita underflow para caso a diferenca de expoentes sejam grandes
        exp = exp_a;                                                     // configura o expoente
    }
    else
    {
        fract_a = (exp_b - exp_a) < 32 ? fract_a >> (exp_b - exp_a) : 0;
        exp = exp_b;
    }

    if (sign_a == sign_b) // analisa os sinais
    {
        fract = fract_a + fract_b;
        sign = sign_a; // seta o sinal
    }
    else
    {
        fract = (fract_a >= fract_b) ? fract_a - fract_b : fract_b - fract_a; // casos de subtracao
        sign = (fract_a >= fract_b) ? sign_a : sign_b;
        if (fract == 0)
            return 0;
    }
    while ((fract & (1 << 24))) // reajuste do expoende e da mantissa
    {
        fract >>= 1;
        exp++;
    }
    while ((fract & (1 << 23)) != (1 << 23))
    {
        fract <<= 1;
        exp--;
    }
    if (exp == 0)
        return 0;

    fract &= FILTER_FRACT;
    return (sign << 31) | (exp << 23) | fract;
}

mfloat subsf3(mfloat a, mfloat b) // subtracao eh uma soma com um numero negativo
{
    return addsf3(a, negsf2(b));
}
