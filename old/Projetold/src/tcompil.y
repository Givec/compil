%{
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#define MAX 1024
#define NAMESIZE 256

int init(FILE *out);
int yyparse(void);
int fileno (FILE *stream); /*non ansi*/
FILE* yyout;
char* file;
int yyerror(char*);
int yylex();
 FILE* yyin; 
 
 /*Compteur de branchements des if/else et fonctions */
 int jump_label=1;
 /*Première adresse disponible pour les variables globales et le main */
 int global_var_adr = 0;
 /*Adresse de la fonction en cours */
 int label_fct_inUse = -1;
 /*Nombre de variables globales (main exclu) */
 int nb_global = 0;

 int nb_IfElse = -1;

 int nb_while = -1;
 
 int label_if[MAX] = {0};

 int label_while[MAX] = {0};

 typedef enum bool{
 	false, true
 }Bool;

 /*Structure des variables */
 typedef struct var{
 	char nom[NAMESIZE]; /*Nom de la variable*/
 	int adr;			/*Adresse de la variable*/
 	Bool is_cst;		/*Variable est constante ou non */
 }Var;
 
 /*Structures des fonctions */
 typedef struct fct_ident{
 char nom[NAMESIZE];/*Nom de la fonction */
 int label;			/*Label de la fonction */
 int nb_alloc;		/*Nombre de variables dans la fonction (paramètres inclus )*/
 int nb_param;		/*Nombre de paramètres*/
 Var var[MAX];		/*Tableau des variables */
}Fct_ident;
 

Var global_var[MAX]; /*Tableau des variables globales */
Fct_ident fct_ident[MAX]; /*Tableau des fonctions */
void inst(const char *);  /*Nom de l'instruction*/
void instarg(const char *,int); /*Nom de l'instruction avec argument */
void comment(const char *);	/*Commentaire sans argument*/
int get_adr_var(char*);	/*Retourne l'adresse de la variable donnée en paramètre*/
int get_label_fct(char*); /*Retourne le label de la fonction donnée en paramètre*/ 
void add_sub(char);	/*Soit ADD soit SUB en fonction du paramètre */
void div_mod(char); /*Soit DIV soit MOD en fonction du paramètre */
void cmp_op(char*); /*Ecrit l'instruction de comparaison en fonction du paramètre */
void check_isNotConst(char*); /*Verifie que le paramètre n'est pas une constante */
void check_var_notExist(char*); /*Vérifie que la variable n'est pas déjà déclarée*/
void create_const(char*); /*Créer une constante*/
void create_var(char*); /*Créer une variable*/
void load_loadr(char*); /*Charge avec la bonne instruction en fonction du paramètre*/
void save_saver(char*); /*Sauvegarde avec la bonne instruction en fonction du paramètre*/
void create_param(char*); /*Créer un paramètre de fonction*/
void set_adr_param(int); /*Associe l'adresse avec le paramètre de fonction */
%}

%union{
	char* string; int entier;
	float reel; char car;
}

%token PRINT CONST PV VRG VAR MAIN ADR ENTIER FREE MALLOC READ RETURN VOID
%token IF ELSE WHILE
%token EGAL ADDSUB DIV STAR
%token LPAR RPAR LACC RACC LSQB RSQB
%token NUM
%token COMP IDENT

%type <entier> Exp  NUM FixIf FixElse NombreSigne ListParam Parametres
%type <string> Variable IDENT COMP ListVar Type VOID ENTIER
%type <car> ADDSUB DIV

%left LPAR
%left RPAR
%left '+'
%left '-'
%left STAR
%left DIV


%%
Prog : DeclConst DeclVar JumpMain DeclFonct DeclMain 						{fprintf(yyout,"#Function : main END\n");};
JumpMain : 																	{instarg("JUMP", 0);};
DeclConst : DeclConst CONST ListConst PV ;
          |;															
ListConst : ListConst VRG IDENT EGAL NombreSigne							{check_var_notExist($3); create_const($3);fprintf(yyout,"#Constant : %s declared\n", $3);}
          | IDENT EGAL NombreSigne  										{check_var_notExist($1); create_const($1);fprintf(yyout,"#Constant : %s declared\n", $1);};
NombreSigne : NUM 															{instarg("SET", $1); inst("PUSH");}
            | ADDSUB NUM 													{instarg("SET", $2); inst("PUSH");};
DeclVar : DeclVar VAR ListVar PV {}						
        | ;																	
ListVar : ListVar VRG Variable 												{$$ = $3; check_isNotConst($3); check_var_notExist($3); create_var($3);fprintf(yyout,"#Variable : %s declared\n", $3);}
        | Variable 															{$$ = $1; check_isNotConst($1); check_var_notExist($1); create_var($1);fprintf(yyout,"#Variable : %s declared\n", $1);};
ListParam: ListParam VRG Variable 											{$$ = 1 + $1; create_param($3);}
			| Variable         												{$$ = 1; create_param($1);};
Variable : STAR Variable  													{$$ = $2;}
         | IDENT 															{$$ = $1;};
DeclMain : EnTeteMain Corps ;
EnTeteMain : MAIN LPAR RPAR 												{instarg("LABEL", 0);fprintf(yyout,"#Function : main START\n"); strcpy(fct_ident[0].nom, "main"); fct_ident[0].label = 0; label_fct_inUse = 0;};
DeclFonct : DeclFonct DeclUneFonct 
          | ;
DeclUneFonct : EnTeteFonct Corps 											{inst("RETURN"); fprintf(yyout, "#Function : %s END\n", fct_ident[label_fct_inUse].nom); label_fct_inUse = -1;};
EnTeteFonct : Type IDENT FixDeclFonct LPAR Parametres RPAR 					{strcpy(fct_ident[jump_label].nom, $2); fct_ident[jump_label].label = jump_label;  jump_label++; fprintf(yyout,"#Function : %s START with %d parameter(s)\n", $2, $5);fct_ident[label_fct_inUse].nb_param = $5; };
FixDeclFonct: 																{label_fct_inUse = jump_label; instarg("LABEL", jump_label);};
Type : ENTIER 																{$$ = $1;}
     | VOID 																{$$ = $1;};
Parametres : VOID 															{$$ = 0;}
           | ListParam 														{$$ = $1;set_adr_param($1);};
Corps : LACC DeclConst DeclVar SuiteInstr RACC ;
SuiteInstr : SuiteInstr Instr
           | ;
InstrComp : LACC SuiteInstr RACC;
Instr : IDENT EGAL Exp PV 													{check_isNotConst($1);inst("POP"); inst("SWAP"); instarg("SET", get_adr_var($1)); inst("SWAP"); save_saver($1);}			 
      | STAR IDENT EGAL Exp PV {}
      | IDENT EGAL MALLOC LPAR Exp RPAR PV {}
      | FREE LPAR Exp RPAR PV {}
      | IF LPAR Exp RPAR FixIf Instr 										{instarg("LABEL", $5);}
      | IF LPAR Exp RPAR FixIf Instr ELSE FixElse Instr %prec ELSE			{instarg("LABEL", $8);}
      | WHILE LPAR LabelWhile Exp FixWhile RPAR Instr EndWhile {}
      | RETURN Exp PV 														{inst("POP"); inst("RETURN");}
      | RETURN PV 															{inst("RETURN");}
      | IDENT LPAR Arguments RPAR PV 										{instarg("CALL", fct_ident[get_label_fct($1)].label);}															
      | IDENT EGAL IDENT LPAR Arguments RPAR PV								{instarg("CALL", fct_ident[get_label_fct($3)].label); inst("SWAP");instarg("SET", get_adr_var($1)); inst("SWAP"); save_saver($1);}
      | READ LPAR IDENT RPAR PV {}
      | PRINT LPAR Exp RPAR PV 												{inst("POP");inst("WRITE");}
      | PV {}
      | InstrComp {} ;
FixIf: 																		{instarg("JUMPF",  $$ =jump_label);nb_IfElse++; label_if[nb_IfElse] = jump_label++;};
FixElse : 																	{instarg("JUMP", $$ = jump_label++); instarg("LABEL", label_if[nb_IfElse--]);};
LabelWhile : 																{instarg("LABEL", jump_label); nb_while++; label_while[nb_while] = jump_label++;}; 
FixWhile : 																	{instarg("JUMPF", jump_label); nb_while++; label_while[nb_while] = jump_label++;};
EndWhile : 																	{instarg("JUMP", label_while[nb_while-1]); instarg("LABEL", label_while[nb_while]); nb_while-=2;};

Arguments : ListExp
          | ;
ListExp : ListExp VRG Exp
        | Exp;
Exp : Exp ADDSUB Exp 														{inst("POP"); inst("SWAP"); inst("POP"); add_sub($2);inst("PUSH");}
    | Exp STAR Exp 															{inst("POP"); inst("SWAP"); inst("POP"); inst("MULT"); inst("PUSH");}
    | Exp DIV Exp 															{inst("POP"); inst("SWAP"); inst("POP"); div_mod($2);inst("PUSH");}
    | Exp COMP Exp 															{ inst("POP"); inst("SWAP"); inst("POP"); cmp_op($2);}
    | ADDSUB Exp 															{if($1 == '-'){ inst("POP"); inst("NEG"); inst("PUSH");}}
    | LPAR Exp RPAR 														{$$ = $2;}
    | Variable 																{instarg("SET", get_adr_var($1)); load_loadr($1); inst("PUSH");}
    | ADR Variable 															{}
    | NUM 																	{instarg("SET", $1); inst("PUSH");};
    | IDENT LPAR Arguments RPAR												{instarg("CALL", fct_ident[get_label_fct($1)].label);inst("PUSH");};
  

%%

int yyerror(char* s) {
  fprintf(stderr,"%s\n",s);
  return 0;
}



void endProgram() {
  fprintf(yyout,"HALT\n");
}

void inst(const char *s){
  fprintf(yyout,"%s\n",s);
}

void instarg(const char *s,int n){
  fprintf(yyout,"%s\t%d\n",s,n);
}


void comment(const char *s){
  fprintf(yyout,"#%s\n",s);
}

void save_saver(char* var){
	int i;
	/* On parcourt l'ensemble des variables globales 	*
	 * Si notre variable ce trouve dans le tableau 		*
	 * global-_var alors on utilise SAVE				*/	 
	for(i = 0; i < global_var_adr; i++){
		if(strcmp(global_var[i].nom, var) == 0){
			inst("SAVE");
			return;
		}
	}
	/* Si ce n'était pas une variable globale on 		*
	 * utilise SAVER pour les fonctions et SAVE pour 	*
	 * le main 											*/
	if(label_fct_inUse > 0) {
		inst("SAVER");
	} else {
		inst("SAVE");
	}		
}
void load_loadr(char* var){
	int i;
		/* On parcourt l'ensemble des variables globales*
	 * Si notre variable ce trouve dans le tableau 		*
	 * global-_var alors on utilise LOAD				*/	
	for(i = 0; i < global_var_adr; i++){
		if(strcmp(global_var[i].nom, var) == 0){
			inst("LOAD");
			return;
		}
	}
	/* Si ce n'était pas une variable globale on 		*
	 * utilise LOADR pour les fonctions et LOAD pour 	*
	 * le main 											*/
	if(label_fct_inUse > 0) {
		inst("LOADR");
	} else {
		inst("LOAD");
	}
}
int get_adr_var(char* var){
	int i;
	/* On parcourt l'ensemble des variables globales	*
	 * Si on trouve la variable, on envoie son adresse  */
	for(i = 0; i< nb_global; i++){
		if(strcmp(global_var[i].nom, var) == 0){
			return global_var[i].adr;
		}
	}
	/* On parcourt l'ensemble des variables de la  	 *
	 * fonction en cours. Si on trouve la variable on 	 *
	 * envoie son adresse.                               */
	for(i = 0; i < fct_ident[label_fct_inUse].nb_alloc; i++){
		if(strcmp(fct_ident[label_fct_inUse].var[i].nom, var) == 0){
			return fct_ident[label_fct_inUse].var[i].adr;
		}
	}
	/* Si on n'a pas trouvé la variable, on affiche un 	 *
	 * message d'erreur.								 */ 
	fprintf(stderr, "error: `%s` undeclared\n", var);
	exit(EXIT_FAILURE);
}

int get_label_fct(char* var){
	int i;
	/* On parcourt le tableau des fonctions et on envoie *
	 * le label de la fonction en paramètre 		 */ 
	for(i = 0; i < jump_label; i++){
		if(strcmp(fct_ident[i].nom, var)==0){
			return fct_ident[i].label;
		}
	}
	/* Si on n'a pas trouvé la fonction, on affiche un 	 *
	 * message d'erreur.								 */
	fprintf(stderr, "error: undefined reference to `%s`\n", var);
	exit(EXIT_FAILURE);
}
void add_sub(char op){
	if(op == '+')
		inst("ADD");
	else
		inst("SUB");
}

void div_mod(char op){
	if(op == '/')
		inst("DIV");
	else
		inst("MOD");
}

void cmp_op(char* op){
	if(strcmp(op, "<") == 0)
		inst("LOW");
	else if (strcmp(op, ">") == 0)
		inst("GREAT");
	else if (strcmp(op, "<=") == 0)
		inst("LEQ");
	else if (strcmp(op, ">=") == 0)
		inst("GEQ");
	else if(strcmp(op, "==") == 0)
		inst("EQUAL");
	else if (strcmp(op, "!=") == 0)
		inst("NOTEQ");
}

void check_var_notExist(char* var){
	int i;
	/* On parcourt l'ensemble des variables globales	*
	 * pour vérifier que la variable n'a pas déjà été 	*
	 * déclarée 										*/
	for(i= 0; i < global_var_adr; i++){
		if(strcmp(global_var[i].nom, var) == 0){
			fprintf(stderr, "error: previous definition of `%s` in global variable\n", var);	
			exit(EXIT_FAILURE);
		}
	}
	/* On vérifie ensuite que la variable n'a pas été	*
	 * déclarée dans la fonction en cours.				*/
	if(label_fct_inUse != -1){
		for(i = 0; i < fct_ident[label_fct_inUse].nb_alloc; i++){
			if(strcmp(fct_ident[label_fct_inUse].var[i].nom, var) == 0){
				fprintf(stderr, "error: previous definition of `%s` in function: %s\n", var, fct_ident[label_fct_inUse].nom);	
				exit(EXIT_FAILURE);
			}
		}
	}	
}

void check_isNotConst(char * var){
	int i;
	/* On parcourt l'ensemble des variables globales	*
	 * pour vérifier que la variable n'est pas une 		*
	 * constante 										*/
	for(i= 0; i < nb_global; i++){
		if(strcmp(global_var[i].nom, var) == 0){
			if(global_var[i].is_cst == true){
				fprintf(stderr, "error: assignment of read-only variable `%s`\n", var);	
				exit(EXIT_FAILURE);
			}
			else
				return;
		}
	}
	/* On vérifie ensuite que la variable n'a pas été	*
	 * déclarée en tant que constante dans la fonction 	*
	 *	en cours.										*/
	if(label_fct_inUse != -1){
		for(i = 0; i < fct_ident[label_fct_inUse].nb_alloc; i++){
			if(strcmp(fct_ident[label_fct_inUse].var[i].nom, var) == 0){
				if(fct_ident[label_fct_inUse].var[i].is_cst == true){
						fprintf(stderr, "error: assignment of read-only variable `%s` in function : %s\n", var, fct_ident[label_fct_inUse].nom);		
						exit(EXIT_FAILURE);
				}
				else
					return;
			}
		}
	}	
}

void create_const(char* var){
	/* Si on ne se trouve pas dans une fonction on 		*
	 * on déclare la constante en variable globale		*/
	if(label_fct_inUse == -1){
		strcpy(global_var[nb_global].nom, var); 
		global_var[nb_global].adr = global_var_adr;
		global_var[nb_global++].is_cst = true; 
		inst("POP"); 
		inst("SWAP"); 
		instarg("SET", global_var_adr++); 
		inst("SWAP"); 
		instarg("ALLOC", 1); 
		inst("SAVE");}
	/* Sinon on la déclare et la sauvegarde dans la		*
	 * fonction en cours.								*/
	else{ 
		strcpy(fct_ident[label_fct_inUse].var[fct_ident[label_fct_inUse].nb_alloc].nom, var);
		fct_ident[label_fct_inUse].var[fct_ident[label_fct_inUse].nb_alloc].is_cst = true;  
		inst("POP");
		 inst("SWAP"); 
		 fct_ident[label_fct_inUse].var[fct_ident[label_fct_inUse].nb_alloc].adr = fct_ident[label_fct_inUse].nb_alloc - fct_ident[label_fct_inUse].nb_param; 
		 instarg("SET", fct_ident[label_fct_inUse].nb_alloc++); 
		 inst("SWAP"); 
		 instarg("ALLOC", 1);
		  inst("SAVER");
		}
}

void create_var(char* var){
	instarg("ALLOC", 1);
	/* Si on ne se trouve pas dans une fonction on 		*
	 * on déclare la variable en globale 				*/
	if(label_fct_inUse == -1){
		strcpy(global_var[nb_global].nom, var); 
		global_var[nb_global].adr = global_var_adr++;
		global_var[nb_global++].is_cst = false;
	}
	/* Sinon on la déclare et la sauvegarde dans la		*
	 * fonction en cours. On prend en compte le nombre 	*
	 * de paramètres si on se trouve en dehors du main 	*/
	else if(label_fct_inUse != 0) {
		strcpy(fct_ident[label_fct_inUse].var[fct_ident[label_fct_inUse].nb_alloc].nom, var);
		fct_ident[label_fct_inUse].var[fct_ident[label_fct_inUse].nb_alloc].adr = fct_ident[label_fct_inUse].nb_alloc - fct_ident[label_fct_inUse].nb_param;
		fct_ident[label_fct_inUse].var[fct_ident[label_fct_inUse].nb_alloc].is_cst = false;
		fct_ident[label_fct_inUse].nb_alloc++;
		
	/* Cas du main */
	} else {
		strcpy(fct_ident[label_fct_inUse].var[fct_ident[label_fct_inUse].nb_alloc].nom, var);
		fct_ident[label_fct_inUse].var[fct_ident[label_fct_inUse].nb_alloc].adr = global_var_adr++;
		fct_ident[label_fct_inUse].var[fct_ident[label_fct_inUse].nb_alloc].is_cst = false;
		fct_ident[label_fct_inUse].nb_alloc++;
		

	}
}
void create_param(char* var){
	int i;
	/* On commence par vérifier que la variable n'existe*
	 * pas 												*/
	for(i= 0; i < global_var_adr; i++){
		if(strcmp(global_var[i].nom, var) == 0){
			fprintf(stderr, "error: `%s` redeclared !\n", var);	
			exit(EXIT_FAILURE);
		}
	}
	/* On stocke le nom du paramètre dans le tableau des * 
	 * variables de la fonction 						 */
	strcpy(fct_ident[label_fct_inUse].var[fct_ident[label_fct_inUse].nb_alloc].nom, var);
	fct_ident[label_fct_inUse].nb_alloc++;
}

void set_adr_param(int nb_param){
	int i;
	/* Pour l'ensemble des paramètres on leur associe 	*
	 * l'adresse 2 - nb_param + i où i correspond à la  *
	 * position du paramètre 							*/ 
	for(i = 0; i < fct_ident[label_fct_inUse].nb_alloc; i++) {
		fct_ident[label_fct_inUse].var[i].adr = -2 - nb_param + i; 
	}
}
int init(FILE* out) {
	yyout = out;
	return 0;
}
	
int main(int argc, char** argv) {
	int i;
	if(argc == 2) {
		yyin = fopen(argv[1],"r"); 
		yyout = stdout;
	} else {
		if(argc == 3) {
			if(strcmp(argv[2], "-o") == 0) {
				file = (char*) malloc(sizeof(char)*strlen(argv[1]));
				strncat(file, argv[1], strlen(argv[1])-4);
				strcat(file, ".vm");
				yyin = fopen(argv[1],"r");
				yyout = fopen(file, "w");
			} else {
				fprintf(stderr, "usage: %s <file> [-o]\n", argv[0]);
				return -1;
			}
		} else {
			fprintf(stderr, "usage: %s <file> [-o]\n", argv[0]);
			return -1;
		}
	}
	init(yyout);
	/* On initialise le tableau des fonctions 		*/
  for(i = 0; i < MAX; i++){
  	fct_ident[i].nb_alloc = 0;
  	fct_ident[i].label = 0;
  	fct_ident[i].nb_param = 0;
  }
	yyparse();
	fclose(yyin);
	fclose(yyout);
	return 0;
}
