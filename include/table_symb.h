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

/* nb max of varaible + param in a function */
#define MAX_VARIABLE 15

typedef struct {
	char id[LEN_ID]; /* NOM ID */
	int is_const; /* is it a const ? */
	int addr_stack; /* addr on the stack */
} symb;

typedef struct {
	char id[LEN_ID]; /* NOM FUNCTION */
	int addr_fun; /* adresse de la fonction */
	int nb_param;
	int nb_alloc;
	symb variables[MAX_VARIABLE];
} fun_ident;

static int table_symb_size;
static int table_fun_size;
symb* table_symb;
fun_ident* table_fun;

void initTableSymb();
void initTableFun();
int verifyConst(const char* id);
void add_symb(const char* id, int is_const, int addr, int cur_fun_index);
void add_fun(const char* id, int nb_param, int addr);
int getIdAddrOnStack(char* id, int stack_max);
void putOnStack(int addr, int val);



#endif
