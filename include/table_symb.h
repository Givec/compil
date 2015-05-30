#ifndef __TABLE_SYMB__
#define __TABLE_SYMB__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yyerror(char* msg);
extern void inst(const char *);
extern void instarg(const char *,int);
extern void comment(const char *);

typedef enum { ENT, CAR, VOI } type_var;

/* length max for an id */
#define LEN_ID 50

/* nb max of varaible + param in a function */
#define MAX_VARIABLE 15

typedef struct {
	char id[LEN_ID]; /* NOM ID */
	int is_const; /* is it a const ? */
	int addr; /* addr on the stack */
	type_var type; /* enum for the type */
} symb;

typedef struct {
	char id[LEN_ID]; /* NOM FUNCTION */
	int addr; /* adresse de la fonction */
	int nb_param;
	int nb_alloc;
	symb variables[MAX_VARIABLE];
	type_var type; /* enum type for the function */
} fun_ident;

int table_symb_size;
int table_fun_size;
symb* table_symb;
fun_ident* table_fun;

void initTableSymb();
void initTableFun();
symb* searchInTable(const char* id, int cur_fun_index);
int verifyConst(const char* id, int cur_fun_index);
void add_symb(const char* id, int is_const, int addr, int cur_fun_index, type_var type);
void add_fun(const char* id, int nb_param, int addr, type_var type);
int getIdAddrOnStack(char* id, int stack_max);
void putOnStack(int addr, int val);



#endif
