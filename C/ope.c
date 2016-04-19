#include <stdio.h>
#include <math.h>
#include "rsa.h"
#include "ope.h"

// Nバイト整数同士の足し算で2Nバイトの整数を生む
void add(unsigned char a[N], unsigned char b[N], unsigned char* sum)
{
    int i;
    unsigned char carry    = 0;
    for (i = 0; i < 2*N; i++) {
        sum[i] = 0;
    }

    for (i = 0; i < N; i++) {
        sum[i] = (a[i] + b[i] + carry) % 256;
        carry  = (a[i] + b[i] + carry) / 256;
    }
    sum[N] = carry;
}
void mul(unsigned char a[N], unsigned char b[N], unsigned char* ans)
{
    ans[0] = (char)((int)a[0] * (int)b[0] % pow_int(256,N));
    ans[1] = (a[0] * b[0]) / pow_int(256, N);
    return;
}

int pow_int(int x, int n)
{
    int i;
    int ans = 1;
    for (i = 0; i < n; i++) {
        ans *= x;
    }
    return ans;
}

