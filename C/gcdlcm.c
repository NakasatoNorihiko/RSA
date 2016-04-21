#include <stdio.h>
#include "rsa.h"

// 32bit(nbyte)のa,bから32bit(nbyte)の最大公約数(gcd)を求める
// void gcd(unsigned char *a, unsigned char *b, unsigned char* gcd, unsigned char n) {
//     int i;
//     int azero = 0; // a == 0なら1になる
//     // gcdに１を代入する
//     for (i = 0; i < n; i++) {
//         if (i == 0) {
//             gcd[i] = 1;
//         } else {
//             gcd[i] = 0;
//         }		 
// 	} 
// 
//     // a == 0かどうかの確認
//     for (i = 0; i < n; i++) {
//         if (a[i] != 0) break;
//         if (i == n - 1) {
//             gcd[i] = 0;
//             return;
//         }
//     }
//     for (i = 0; i < n; i++) {
//         if (b[i] != 0) break;
//         if (i == n - 1) {
//             gcd[i] = 0;
//             return;
//         }
//     }
// 
//     while (azero > 0) {
//         if ((a[0] % 2 == 0) && (b[0] % 2 == 0)) {
//             for (i = 0; i < n; i++) {
//                 if (i == 0) {
//                     a[0]   = a[0] >> 2;
//                     g[n-1] = g[n-1] << 2;
//                 } else {
//                     a[i]     = a[i] >> 2 + (a[i+1] % 2)*256;
//                     g[n-i-1] = g[n-i-1] << 2 + (a[n-i-2] / 128);
//                 }
//             }
//         } else if ((a[0] % 2 ==0) && (b[0] % 2 != 0) {
//             for (i = 0; i < n; i++) {
//                 if (i == 0) {
//                     a[0]   = a[0] >> 2;
//                 } else {
//                     a[i]     = a[i] >> 2 + (a[i+1] % 2)*256;
//                 }
//             }
//         } else if (
//     return;
// }

unsigned int gcd_int(unsigned int a, unsigned int b) {
    unsigned int g = 1;

    if (a == 0) return 0;
    if (b == 0) return 0;

    while (a > 0) {
        if (a % 2 == 0 && b % 2 == 0) {
            a = a >> 1;
            b = b >> 1;
            g = g << 1;
        } else if (a % 2 == 0 && b % 2 == 1) {
            a = a >> 1;
        } else if (a % 2 == 1 && b % 2 == 0) {
            b = b >> 1;
        } else {
            if (a >= b) {
                a = (a-b) >> 1;
            } else {
                b = (b-a) >> 1;
            }
        }
    }
    return g * b;
}
