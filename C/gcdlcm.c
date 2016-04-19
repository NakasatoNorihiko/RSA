#include <stdio.h>
#include "rsa.h"

// 32bit(Nbyte)のa,bから32bit(Nbyte)の最大公約数(gcd)を求める
void gcd(char a[N], char b[N], char* gcd) {
    int i;
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
