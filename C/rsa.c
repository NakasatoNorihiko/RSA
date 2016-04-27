#include <stdio.h>
#include <stdlib.h>
#include "rsa.h"
#include "ope.h"
#include "create_ld.h"

// int main(int argc, char *argv[]) {
//     int i;
//     unsigned char a[N];
//     unsigned char b[N];
//     unsigned char ans[N+1];
//     unsigned int a_int = atoi(argv[1]);
//     unsigned int b_int = atoi(argv[2]);
//     unsigned int q, r;
// //    div_int(&a_int, &b_int, &q, &r);
// //
//     for (i = 0; i < 100; i++) {
//         a_int = rand() % 100000 + 1;
//         b_int = rand() % a_int + 1;
//         q = 0;
//         r = 0;
//         div_binary(&a_int, &b_int, &q, &r);
//         printf("[%d = %d * %d + %d]\n", a_int, b_int, q, r);
//         printf("[%x = %x * %x + %x]\n", a_int, b_int, q, r);
//     }
// //     printf("%u %u -> %u\n", a_int, b_int, gcd);
// //     for (i = 0; i < N; i++) {
// //         a[i] = (unsigned char)((atoi(argv[1]) / pow_int(256, i)) % 256);
// //         b[i] = (unsigned char)((atoi(argv[2]) / pow_int(256, i)) % 256);
// //     }
// //    printf("%u (%u)\n", (unsigned int)ans[1]*256 + (unsigned int)ans[0], atoi(argv[1])*atoi(argv[2]));
//     
//     return 0;
// }

int main(int argc, char *argv[])
{
    int e, L, d;

    e = 79;
    L = 176;
    d = create_d(e,L);
    printf("%d %d -> %d\n", e, L, d);

    e = 828;
    L = 2793;
    d = create_d(e, L);
    printf("%d %d -> %d\n", e, L, d);

    return 0;
}
