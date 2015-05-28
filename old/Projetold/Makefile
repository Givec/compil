CC=gcc
CFLAGS=-Wall
LDFLAGS=-Wall -lfl
EXEC=src/tcompil

all: $(EXEC) clean

$(EXEC): $(EXEC).o lex.yy.o
	gcc  -o $@ $^ $(LDFLAGS)
	mv $@ bin/tcompil

$(EXEC).c: $(EXEC).y
	bison -d -o $(EXEC).c $(EXEC).y

$(EXEC).h: $(EXEC).c

lex.yy.c: $(EXEC).lex $(EXEC).h
	flex $(EXEC).lex

%.o: %.c
	gcc -o $@ -c $< $(CFLAGS)

clean:
	rm -f src/*.o lex.yy.* $(EXEC).[ch]
