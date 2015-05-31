%{
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "../include/table_symb.h"

typedef enum { false, true }Bool;

	FILE* yyout;
	int yyerror(char*);
	int yylex();
	FILE* yyin; 
	int stack_cur = 0;
	
	int cur_fun_index = -1;
	int nb_arg_cur = 0;
	int jump_label = 0;
	int jump_fin_while = 0;
	type_var cur_type;
	int cur_const;
	
	void alloc(int* cur);
	void inst(const char *);
	void instarg(const char *,int);
	void comment(const char *);
		
	/*les fonctions utilisés*/
	int getsigne(char addsub);
	void add_sub(char op);
	void div_star(char op);
	void comp( char* bop);
	void neg(void);
	void bope (char* bop);
	int newLabel(void);
	int newLabelFun(void);
	type_var getType(char* type); /* retourne l'enum en fonction du type */

%}

%union {
   char ident[50];
   char type[50];
   char caractere;
   int entier;
   char comp[3];
   char bool[3];
}

%token NUM CARACTERE
%token IDENT
%token COMP
%token ADDSUB
%token DIVSTAR
%token BOPE
%token NEGATION WHILE IF ELSE
%token EGAL PV VRG LPAR RPAR LACC RACC LSQB RSQB
%token CONST
%token VOID RETURN
%token MAIN PRINT READ READCH
%token TYPE TYPEFUN

%left SEULIF
%left ELSE
%left BOPE
%left COMP
%left ADDSUB
%left DIVSTAR
%left NEGATION
%left UNAIRE    /*operation unaire toute derniere*/



%type <ident> IDENT 
%type <entier> NUM NombreSigne Exp LValue JUMPIF JUMPE
%type <type> TYPE TYPEFUN
%type <caractere> CARACTERE ADDSUB DIVSTAR
%type <comp> BOPE COMP

%%

PROG 		: DeclConst DeclVarPuisFonct DeclMain
			;

DeclConst 	: CONST TYPE {cur_type = getType($2); cur_const = 1;} ListConst PV {cur_const = 0;} DeclConst
			| /* rien */
			;
	
ListConst 	: ListConst VRG {alloc(&stack_cur);} IDENT EGAL Litteral
			| {alloc(&stack_cur);} IDENT EGAL Litteral
			;
	
Litteral 	: NombreSigne								{putOnStack(stack_cur-1, $1);}
			| CARACTERE 								{putOnStack(stack_cur-1, $1);}
			;
	
NombreSigne : NUM 										{ $$ = $1;}
			| ADDSUB NUM 								{ $$ = (getsigne($1) * $2);}
			;
	
DeclVarPuisFonct : TYPE { cur_type = getType($1);} ListVar PV DeclVarPuisFonct
			| {instarg("JUMP",0);} DeclFonct
			| /* rien */
			;
	
ListVar 	: ListVar VRG {alloc(&stack_cur);} Ident 
			| {alloc(&stack_cur);} Ident
			;
	
Ident 		: IDENT 									{ add_symb($1, cur_const, stack_cur-1, cur_fun_index, cur_type);}
			;
	
Tab			: Tab LSQB NUM RSQB
			|
			; 
			
DeclMain	: EnTeteMain {cur_fun_index = -1; instarg("LABEL", 0);} Corps
			;
			
EnTeteMain	: MAIN LPAR RPAR
			;
			
DeclFonct	: DeclFonct DeclUneFonct
			| DeclUneFonct
			;
			
DeclUneFonct: EnTeteFonct {instarg("LABEL", cur_fun_index);} Corps
			;

EnTeteFonct	: { cur_fun_index = newLabel();} TYPEFUN IDENT LPAR Parametres RPAR { add_fun($3, nb_arg_cur, cur_fun_index, getType($2));}
			| { cur_fun_index = newLabel();} VOID IDENT LPAR Parametres RPAR { add_fun($3, nb_arg_cur, cur_fun_index, VOI);}
			;
			
Parametres	: VOID {nb_arg_cur = 0; /* pas d'args */}
			| ListTypVar
			;
			
ListTypVar	: ListTypVar VRG TYPE IDENT {nb_arg_cur++;}
			| TYPE IDENT {nb_arg_cur++; }
			;

Corps		: LACC DeclConst DeclVar SuiteInstr RACC
			;

DeclVar		: DeclVar TYPE ListVar PV
			|
			; 

SuiteInstr	: SuiteInstr Instr
			|
			;

InstrComp	: LACC SuiteInstr RACC
			;
			
JUMPFALSE	: {inst("POP"); instarg("JUMPF", jump_fin_while = newLabel());}
			;
			
JUMPIF 		: {inst("POP");	instarg("JUMPF", $$ = newLabel());}
			;
			
JUMPE 		: {instarg("JUMP", $$ = newLabel());}
			;
			
			
Instr		: LValue EGAL Exp PV
			| IF LPAR Exp RPAR JUMPIF Instr %prec SEULIF{instarg("LABEL",$5); }
			| IF LPAR Exp RPAR JUMPIF Instr ELSE JUMPE 	{instarg("LABEL",$5); } Instr { instarg("LABEL",$8); }
			| WHILE LPAR {instarg("LABEL", jump_label = newLabel());} Exp JUMPFALSE RPAR Instr {instarg("JUMP", jump_label);} {instarg("LABEL", jump_fin_while);}		
			| RETURN Exp PV								{inst("POP"); inst("RETURN");}
			| RETURN PV									{inst("RETURN");}
			| IDENT LPAR Arguments RPAR PV				{startFun(stack_cur, $1);}
			| READ LPAR IDENT RPAR PV					{inst("READ");inst("PUSH");}
			| READCH LPAR IDENT RPAR PV					{inst("READCH");inst("PUSH");}
			| PRINT LPAR Exp RPAR PV					{inst("POP");inst("WRITE");}
			| PV										{}
			| InstrComp									{}
			;



Arguments 	: ListExp
			| 
			;
          
LValue		: IDENT /* TabExp */ 						{ /* if(NULL == searchInTable($1, cur_fun_index)) {yyerror("Undeclared variable");}*/ $$ = getIdAddrOnStack($1, cur_fun_index);}
			;
				
ListExp 	: ListExp VRG Exp
			| Exp;
        
Exp 		: Exp ADDSUB Exp 							{inst("POP"); inst("SWAP"); inst("POP"); add_sub($2); inst("PUSH");}
			| Exp DIVSTAR Exp							{inst("POP"); inst("SWAP"); inst("POP"); div_star($2); inst("PUSH");}
			| Exp COMP Exp 								{ inst("POP"); inst("SWAP"); inst("POP"); comp($2);}
			| ADDSUB Exp %prec UNAIRE								{if($1 == '-'){ inst("POP"); inst("NEG"); inst("PUSH");}}
			| Exp BOPE Exp								{inst("POP"); inst("SWAP"); inst("POP"); bope($2); inst("PUSH");}
			| NEGATION Exp								{inst("POP"); neg(); inst("PUSH");}
			| LPAR Exp RPAR 							{$$ = $2;}
			| LValue									{instarg("SET", $1); inst("LOAD"); inst("PUSH"); }
			| NUM 										{instarg("SET", $1); inst("PUSH");}
			| IDENT LPAR Arguments RPAR					{startFun(stack_cur, $1);}
		
%%


int yyerror(char* s) {
  fprintf(stderr,"%s\n",s);
  return 0;
}

void endProgram() {
  fprintf(yyout, "HALT\n");
}

void alloc(int* cur){
	instarg("ALLOC", 1);
	*cur = *cur + 1;
}	

void inst(const char *s){
  fprintf(yyout, "%s\n",s);
}

void instarg(const char *s,int n){
  fprintf(yyout, "%s\t%d\n",s,n);
}

void comment(const char *s){
  fprintf(yyout, "#%s\n",s);
}

int getsigne(char addsub){
	if(addsub == '+')
		return 1;
	return -1;
}

type_var getType(char* type){
	if(strcpy(type, "entier") == 0)
		return ENT;
	return CAR;
}

void add_sub(char op) {
	if(op == '+')
		inst("ADD");
	else
		inst("SUB");
}

void div_star(char op){
	if(op == '/')
		inst("DIV");
	if( op == '*')
		inst("MULT");
	else
		inst("MOD");
}

void comp( char* bop){
	if(strcmp(bop, "==") == 0)
		inst("EQUAL");
	if(strcmp(bop,">") == 0)
		inst("GREATER");
	if(strcmp(bop,"<") == 0)
		inst("LESS");
	if(strcmp(bop,">=") == 0)
		inst("GEQ");
	if(strcmp(bop,"<=") == 0)
		inst("LEQ");
	else
		inst("NOTEQ");
}

void neg(void){
	inst("SWAP");   /*reg1 = reg2*/
	inst("PUSH");  	/*conservation de la valeur ancienne reg2*/
	instarg("SET",1);
	inst("ADD");	  /*la somme de reg1 et reg2*/
	inst("SWAP");	  /*reg 2 = la somme*/ 
	instarg("SET",2);
	inst("SWAP");
	inst("MOD");    /*la somme % 2*/
	inst("SWAP");   /*le resultat de negation en reg2 pour pop reg2 precedent*/
	inst("POP");
	inst("SWAP");   /*resultat negation en reg1*/
}

void bope (char* bop){
	if( strcmp(bop,"&&") == 0){
		inst("ADD");
		inst("SWAP");
		instarg("SET",2);
		inst("EQUAL");
	} else {
		inst("ADD");
		inst("SWAP");
		instarg("SET",0);
		inst("NOTEQ");
	}	
}

int newLabel(void){
	static int label = 1;
	return label++;
}

int newLabelFun(void){
	static int labelFun = 0;
	return labelFun++;
}


int main(int argc, char** argv) {
  if(argc==3){
	if( strcmp(argv[2], "-o") == 0){
		int n = strlen(argv[1]);
		char* input_file = (char*) malloc(sizeof(char) * (n - 1));
		if(strcmp(argv[1] + (n-4), ".tpc") == 0){
			memcpy(input_file, argv[1], n-4);
			memcpy(input_file + (n-4), ".vm", 3);
			
			yyout = fopen(input_file,"w");
			yyin = fopen(argv[1], "r");
		} else {
			fprintf(stderr,"usage: %s [src] -o\n",argv[0]);
			return 1;
		}
	} else {
		fprintf(stderr,"usage: %s [src] -o\n",argv[0]);
		return 1;
	}
  }
  else if(argc==1){
    yyout = stdout;
    yyin = stdin;
  }
  else{
    fprintf(stderr,"usage: %s [src]\n",argv[0]);
    return 1;
  }
  
  /* initialisation tables */
  initTableSymb();
  initTableFun();
  
  yyparse();
  endProgram();
  return 0;
}
