#include <stdio.h>
#include <stdlib.h>
#include "rsa.h"
#include "ope.h"

int main(int argc, char *argv[]) {
    int i;
    unsigned char a[N];
    unsigned char b[N];
    unsigned char ans[2];
    for (i = 0; i < N; i++) {
        a[i] = (unsigned char)((atoi(argv[1]) / pow_int(256, i)) % 256);
        b[i] = (unsigned char)((atoi(argv[2]) / pow_int(256, i)) % 256);
    }
    sub(a,b,ans,N);
    printf("%u\n", (unsigned int)ans[1]*256 + (unsigned int)ans[0]);
    //printf("%u\n", (unsigned int)ans[1]*256 + (unsigned int)ans[0]);
//    printf("%d\n", comp(&a, &b));
	return 0;
}
