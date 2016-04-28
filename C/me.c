#include <stdio.h>
#include <stdlib.h>

// S = a^m mod N を求める
int me(int a, int N, int m)
{
    int S = 1;
    int j, n;

    n = 0;
    while ((m >> n) != 0) n++;

    for (j = n - 1; j >= 0; j--) {
        S = (S * S) % N;
        if ((m >> j) % 2 == 1) {
            S = (S * a) % N;
        }
    }
    return S;
}

// テスト用
// int main(int argc, char *argv[])
// {
//     int a = atoi(argv[1]);
//     int N = atoi(argv[2]);
//     int m = atoi(argv[3]);
//     int S;
// 
//     S = me(a, N, m);
//     
//     printf("%d = %d^%d mod %d\n", S, a, m, N);
//     return 0;
// }
