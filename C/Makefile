# プログラム名とオブジェクトファイル名
PROGRAM = rsa
OBJS = rsa.o ope.o gcdlcm.o create_ld.o

# 定義済みマクロの再定義
CC = gcc
CFLAGS = -Wall -O2

# サフィックスルール適用対象の拡張子の定義
.SUFFIXES: .c .o

# プライマリターゲット
$(PROGRAM): $(OBJS)
	$(CC) -o $(PROGRAM) $^

# サフィックスルール
.c.o:
	$(CC) $(CFLAGS) -c $<

# ファイル削除用ターゲット
.PHONY: clean
clean:
	$(RM) $(PROGRAM) $(OBJS)

# ヘッダファイルの依存関係
rsa.o: rsa.h ope.h create_ld.h
ope.o: rsa.h ope.h
gcdlcm.o: rsa.h
