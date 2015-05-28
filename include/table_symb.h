#ifndef __TABLE_SYMB__
#define __TABLE_SYMB__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yyerror(char* msg);
extern void inst(const char *);
extern void instarg(const char *,int);
extern void comment(const char *);

/* length max for an id */
#define LEN_ID 50

typedef struct {
	char id[LEN_ID]; /* NOM ID */
	int is_const; /* is it a const ? */
	int addr_stack; /* addr on the stack */
} symb;

symb table_symb[20];

void add_symb(const char* id, int is_const, int addr);
int getIdAddrOnStack(char* id, int stack_max);
void putOnStack(int addr, int val);



#endif
