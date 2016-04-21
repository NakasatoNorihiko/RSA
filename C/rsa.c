#include <stdio.h>
#include <stdlib.h>
#include "rsa.h"
#include "ope.h"

int main(int argc, char *argv[]) {
    int i;
    unsigned char a[N];
    unsigned char b[N];
    unsigned char ans[N+1];
    unsigned int a_int = atoi(argv[1]);
    unsigned int b_int = atoi(argv[2]);
    unsigned int q, r;
    div_np1_n_int(&a_int, &b_int, &q, &r, 1);
//     printf("%u %u -> %u\n", a_int, b_int, gcd);
    for (i = 0; i < N; i++) {
        a[i] = (unsigned char)((atoi(argv[1]) / pow_int(256, i)) % 256);
        b[i] = (unsigned char)((atoi(argv[2]) / pow_int(256, i)) % 256);
    }
//    printf("%u (%u)\n", (unsigned int)ans[1]*256 + (unsigned int)ans[0], atoi(argv[1])*atoi(argv[2]));
    
    return 0;
}
