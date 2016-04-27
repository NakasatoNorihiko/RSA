#include <stdio.h>
int create_d(int e, int L) 
{
    int d, d_n, d_nn, r, r_n, r_nn, q;

    d = 1;
    d_n = 0;
    r = e;
    r_n = L;

    while (r_n != 0) {
        q = r / r_n;
        r_nn = r % r_n;
        d_nn = d - d_n * q;
        printf("(d, d_n, d_nn, r, r_n, r_nn) = (%d, %d, %d, %d, %d, %d)\n",d, d_n, d_nn, r, r_n, r_nn);
        r   = r_n;
        r_n = r_nn;
        d   = d_n;
        d_n = d_nn;
    }
    
    if (d < 0) d = d + L;
    return d;
}
