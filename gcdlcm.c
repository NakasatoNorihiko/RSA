#include <stdio.h>

#define N 4

// 32bit(4byte)のa,bから32bit(4byte)の最大公約数(gcd)を求める
void gcd(char a[N], char b[N], char* gcd) {
    // gcdに１を代入する
    for (i = 0; i < N; i++) {
        if (i == 0) {
            gcd[i] = 1;
        } else {
            gcd[i] = 0;
        }		 
	} 
    return;
}
