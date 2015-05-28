CC=colorgcc
CFLAGS=-Wall
LDFLAGS=-Wall -lfl
SRC=src/
INCLUDE=include/
BIN=bin/
EXEC=tpcompil

all: $(EXEC) clean

$(EXEC): $(BIN)$(EXEC).o lex.yy.o $(BIN)table_symb.o 
	$(CC)  -o $@ $^ $(LDFLAGS)

$(SRC)$(EXEC).c: $(SRC)$(EXEC).y
	bison -d -v -o $@ $^

$(INCLUDE)$(EXEC).h: $(SRC)$(EXEC).c

lex.yy.c: $(SRC)$(EXEC).lex $(INCLUDE)$(EXEC).h
	flex $<

$(BIN)%.o: $(SRC)%.c
	$(CC) -o $@ -c $< $(CFLAGS)

clean:
	rm -f $(BIN)*.o lex.yy.c $(EXEC).[ch]
