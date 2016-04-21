#include <stdio.h>
#include <math.h>
#include "rsa.h"
#include "ope.h"

// nバイト整数同士の足し算で2nバイトの整数を生む
void add(unsigned char* a, unsigned char* b, unsigned char* sum, unsigned char n)
{
    int i;
    unsigned char carry    = 0;
    for (i = 0; i < 2*n; i++) {
        sum[i] = 0;
    }

    for (i = 0; i < n; i++) {
        sum[i] = (a[i] + b[i] + carry) % 256;
        carry  = (a[i] + b[i] + carry) / 256;
    }
    sum[n] = carry;
}
// Nバイト整数同士の引き算でNバイトの整数を生む
// 数値が大きいほうから小さいほうを引く
void sub(unsigned char *a, unsigned char *b, unsigned char* diff, unsigned char n)
{
    int i;
    unsigned char carry = 0;
    unsigned char *big, *small;
    if (comp(a,b,n) > 0) {
        big   = a;
        small = b;
    } else if (comp(a,b,n) < 0) {
        big   = b;
        small = a;
    } else {
        for (i = 0; i < n; i++) {
            diff[i] = 0;
            return;
        }
    }
    printf("%u %u\n", big[0], small[0]);
    for (i = 0; i < n; i++) {
        if ((big[i] < (small[i]+carry))) {
            diff[i] = (256+big[i]) - (small[i]+carry);
            carry = 1;
        } else {
            diff[i] = big[i] - small[i] - carry;
            carry = 0;
        }
    }
    return;
}
// nバイト整数同士の掛け算で2nバイトの整数を生む
void mul(unsigned char *a, unsigned char *b, unsigned char* ans, unsigned char n)
{
    char res_one[n+1];
    int i, j;
    for (i = 0; i < 2*n; i++) {
        ans[i] = 0;
    }

    for (i = 0; i < n; i++) {
        mul_one(a, b[i], res_one, n);
        for (j = 0; j < n + 1; j++) {
            ans[i+j] += res_one[j];
        }
    }
    return;
}

// nバイト整数*1バイト整数の掛け算でn+1バイトの整数を生む
void mul_one(unsigned char *a, unsigned char b, unsigned char *ans, unsigned char n)
{
    int i;
    unsigned char carry = 0;

    if (b == 0) {
        for (i = 0; i < n+1; i++) {
            ans[i] = 0;
        }
        return;
    }
    
    for (i = 0; i < n; i++) {
        ans[i] = (carry + ((unsigned int)a[i] * (unsigned int)b)) % 256;
        carry  = (carry + ((unsigned int)a[i] * (unsigned int)b)) / 256;
    }
    ans[n] = carry;
    return;
}

// n+1桁の整数をn桁の整数で除算する
// void div_np1_n(unsigned char *dividend, unsigned char *divisor, unsigned char *ans, unsigned char n) 
// {
//     
// }
int pow_int(int x, int n)
{
    int i;
    int ans = 1;
    for (i = 0; i < n; i++) {
        ans *= x;
    }
    return ans;
}

// nバイトの整数をmバイト左シフトする
void left_shift(unsigned char *ori, unsigned char *res, unsigned char n, unsigned char m)
{
    int i;
    for (i = 0; i < n; i++) {
        if (i >= m) {
            res[i] = ori[i-m];
        } else {
            res[i] = 0;
        }
    }
}

void right_shift(unsigned char *ori, unsigned char *res, unsigned char n, unsigned char m)
{
    int i;
    for (i = 0; i < n; i++) {
        if (i < n-m) {
            res[i] = ori[i+m];
        } else {
            res[i] = 0;
        }
    }
}
// a > b なら1, a < bなら-1, a = bなら0を返す
int comp(unsigned char *a, unsigned char *b, unsigned char n) 
{
    int i = n-1;
    while (i >= 0) {
        if (a[i] > b[i]) {
            return 1;
        } else if (a[i] < b[i]) {
            return -1;
        }
        i--;
    }
    return 0;
}
