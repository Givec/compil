%{
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "../include/table_symb.h"

	FILE* yyout;
	int yyerror(char*);
	int yylex();
	FILE* yyin; 
	int stack_cur = 0;
	int jump_label=0; 
	
	void alloc(int* cur);
	void inst(const char *);
	void instarg(const char *,int);
	void comment(const char *);
	int getsigne(char addsub);
	
/*	typedef enum { ENT, CAR } type_var; */

%}

%union {
   char ident[50];
   char type[50];
   char caractere;
   int entier;
}

%token NUM CARACTERE
%token TYPE
%token PV VRG
%token CONST
%token IDENT
%token EGAL ADDSUB
%token PRINT

%type <ident> IDENT
%type <entier> NUM NombreSigne
%type <type> TYPE
%type <caractere> CARACTERE ADDSUB

%%

PROG : DeclConst DeclVarPuisFonct Print
	;

DeclConst : DeclConst CONST ListConst PV | /* rien */
	;
	
ListConst : ListConst VRG {alloc(&stack_cur);} IDENT EGAL Litteral { add_symb($4, 1, stack_cur-1); } 
	| {alloc(&stack_cur);} IDENT { add_symb($2, 1, stack_cur-1);} EGAL Litteral
	;
	
Litteral : NombreSigne {putOnStack(stack_cur-1, $1);}
	| CARACTERE {putOnStack(stack_cur-1, $1);}
	;
	
NombreSigne : NUM { $$ = $1;}
	| ADDSUB NUM { $$ = (getsigne($1) * $2);}
	;
	
DeclVarPuisFonct : TYPE ListVar PV DeclVarPuisFonct
	| /* DeclFonct */
	;
	
ListVar : ListVar VRG {alloc(&stack_cur);} Ident 
	| {alloc(&stack_cur);} Ident
	;
	
Ident : IDENT { add_symb($1, 0, stack_cur-1);}
	;

Print : /* rien */ | Print PRINT IDENT PV { inst("PUSH"); instarg("SET", getIdAddrOnStack($3, stack_cur)); inst("LOAD"); inst("WRITE"); inst("POP");} 
	;
	

%%


int yyerror(char* s) {
  fprintf(stderr,"%s\n",s);
  return 0;
}

void endProgram() {
  printf("HALT\n");
}

void alloc(int* cur){
	instarg("ALLOC", 1);
	*cur = *cur + 1;
}	

void inst(const char *s){
  printf("%s\n",s);
}

void instarg(const char *s,int n){
  printf("%s\t%d\n",s,n);
}

void comment(const char *s){
  printf("#%s\n",s);
}

int getsigne(char addsub){
	if(addsub == '+')
		return 1;
	return -1;
}

int main(int argc, char** argv) {
  if(argc==3){
	if( strcmp(argv[1], "-o") == 0)
		yyout = fopen("test.vm","w");
		yyin = fopen(argv[2], "r");
  }
  else if(argc==1){
    yyout = stdout;
    yyin = stdin;
  }
  else{
    fprintf(stderr,"usage: %s [src]\n",argv[0]);
    return 1;
  }
  
  yyparse();
  endProgram();
  return 0;
}
