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
    unsigned char res_one[n+1];
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

// 2進数の整数を2進数の整数で除算する
void div_binary(unsigned int *a, unsigned int *b, unsigned int *q, unsigned int *r)
{
    int qq,i;
    int sizea = 0;
    int sizeb = 0;
    unsigned int ina, inb;

    ina = *a;
    inb = *b;
    *q = 0;
    *r = 0;

    while ((ina >> sizea) != 0) sizea++;
    while ((inb >> sizeb) != 0) sizeb++;

    printf("sizea = %d sizeb=%d\n", sizea, sizeb);
    if (sizea < sizeb) {
        *q = 0;
        *r = *a;
        printf("bad size\n");
    }

//     printf("%x = %x * %x + %x\n", *a, inb, *q, ina);
    // iは最上位桁
    for (i = sizea; i >= sizeb; i--) {
        *q  = *q << 1;
//         printf("%u\n", (ina >> (i-1))%2);
//        if ((ina >> (i-1)) % 2 == 1) {
//             printf("%d %d\n", ina, inb << (i-sizeb));
            if ((ina >= (inb << (i-sizeb)))) {
                ina = ina - (inb << (i-sizeb));
                (*q)++;
            }
//        }
        printf("%x = %x * %x + %x\n", *a, inb, (*q << (i-sizeb)), ina);
    }
    *r = ina;
}
// n+1桁(256進数)の整数をn桁(256進数）の整数で除算する
// void div_np1_n(unsigned char *a, unsigned char *b, unsigned char *ans, unsigned char n) 
// {
//     int D = 256;
//     unsigned char k = (unsigned char)(D/((int)b[n-1]+1));
//     unsigned char ak[8], bk[8];
//     mul(a, k, ak, n+1);
//     mul(b, k, bk, n);
// }

// n+1桁（16進数）の整数をn桁（16進数）の整数で除算する
void div_np1_n_int(unsigned int *a, unsigned int *b, unsigned int *q, unsigned int *r, unsigned int n) 
{
    int D = 16; // 2**d = D
    int d = 4;  // 2**d = D
    int qq; // 仮の商
    int k = 0;  // ずらす回数
    unsigned int ina, inb;

    ina = *a;
    inb = *b;
    *q = 0;
    *r = 0;

    if (ina == 0) {
        return;
    }

    while ((inb / pow_int(2, n-1)) < D/2) {
        ina = ina << 1;
        inb = inb << 1;
        k++;
    }

    printf("ina=%d inb=%d *q=%d *r=%d\n", ina, inb, *q, *r);
    if ((ina >> (d*n)) > ((inb >> (d*(n-1))))) { // inaが大きすぎる場合
        printf("big ina\n");
        qq = (ina >> d*n) / (inb >> (d*(n-1)));
        while (qq * inb > ina && qq > 0) {
            qq--;
        }
        *q = qq*D;
        *r = (ina - qq *inb*D);
        ina -= (*q)*inb;
        printf("%d = %d *  %d + %d\n", *a, *b, *q, *r);
    }
//    printf("ina=%d inb=%d *q=%d *r=%d\n", ina, inb, *q, *r);

    qq = (ina >> d*(n-1)) / (inb >> d*(n-1));
    if (qq == 0) {
        *r = ina >> k;
        printf("%x = %x *  %x + %x\n", *a, *b, *q, *r);
        return;
    }

    printf("ina=%x inb=%x qq=%x *q=%x\n", ina, inb, qq, *q);
    
    while (qq * inb > ina && qq > 0) {
        qq--;
        printf("ina=%d inb=%d qq=%d *q=%d\n", ina, inb, qq, *q);
    }
    *q += qq;
    *r = (ina - qq * inb) >> k;

    printf("%x = %x *  %x + %x\n", *a, *b, *q, *r);
}

void div_int(unsigned int *a, unsigned int *b, unsigned int *q, unsigned int *r)
{
    int D = 16;
    int d = 4;
    int i;
    unsigned int ina = *a;
    unsigned int inb = *b;
    unsigned int bufa = *a;
    unsigned int bufq, bufr;
    int sizea = (size(*a) + d-1) / d;
    int sizeb = (size(*b) + d-1) / d;
    *q = 0;
    *r = 0;
    if (sizea == sizeb) {
        div_np1_n_int(&bufa, &inb, &bufq, &bufr, sizeb);
        *q = bufq;
        *r = bufr;
        return;
    }   

    bufa = bufa >> (sizea - sizeb - 1) * d;
    for (i = (sizea - sizeb - 1)*d; i >= 0; i -= d) { 
        printf("bufa = %d bufb=%d\n", bufa, inb); 
        div_np1_n_int(&bufa, &inb, &bufq, &bufr, sizeb);
        *q += (bufq << i);
        bufa = (bufr << d) + (*a >> (i-d)) % D;
    }
    *r = bufr;
    return;
}

int size(unsigned int a)
{
    int size = 0;
    while ((a >> size) != 0) size++;
    return size;
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
// *a > b なら1, a < bなら-1, a = bなら0を返す
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
