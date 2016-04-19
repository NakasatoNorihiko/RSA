#include <stdio.h>
#include <stdlib.h>
#include "rsa.h"
#include "ope.h"

int main(int argc, char *argv[]) {
    unsigned char a = (unsigned char)atoi(argv[1]);
    unsigned char b = (unsigned char)atoi(argv[2]);
    unsigned char ans[2];
    add(&a,&b,ans);
    printf("%u\n", (unsigned int)ans[1]*256 + (unsigned int)ans[0]);
	return 0;
}
