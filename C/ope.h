#ifndef _OPE_H_
#define _OPE_H_

void add(unsigned char*, unsigned char*, unsigned char*, unsigned char);
void sub(unsigned char*, unsigned char*, unsigned char*, unsigned char);
void mul(unsigned char*, unsigned char*, unsigned char*, unsigned char);
void mul_one(unsigned char*, unsigned char, unsigned char*, unsigned char);
void div_np1_n_int(unsigned int*, unsigned int*, unsigned int*, unsigned int*, unsigned int);
void div_int(unsigned int*, unsigned int* ,unsigned int*, unsigned int*);
int size (unsigned int);
int  pow_int(int, int);
int  comp(unsigned char*, unsigned char*, unsigned char);

#endif // _OPE_H_
