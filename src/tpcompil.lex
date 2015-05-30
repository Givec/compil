%{
	#include "src/tpcompil.h"
%}
%%
[ \t\n]+ ;
"entier" {strcpy(*(&yylval.type), yytext); return TYPE;}
"caractere" {strcpy(*(&yylval.type), yytext); return TYPE;}
"entier/ [a-zA-Z]+ (" {strcpy(*(&yylval.type), yytext); return TYPEFUN;}
"caractere/ [a-zA-Z]+ (" {strcpy(*(&yylval.type), yytext); return TYPEFUN;}
"print" {return PRINT;}
"const" {return CONST;}
"void" {return VOID;}
"readch" {return READCH;}
"read" {return READ;}
"main" {return MAIN;}
"while" {return WHILE;}
"if" {return IF;}
"else" {return ELSE;}
"return" {return RETURN;}
"=" {return EGAL;}
";" {return PV;}
"," {return VRG;}
"(" {return LPAR;}
")" {return RPAR;}
"{" {return LACC;}
"}" {return RACC;}
"[" {return LSQB;}
"]" {return RSQB;}
"!" { /*(yylval.caractere = yytext[0]);*/ return NEGATION;}

[0-9]+ {sscanf(yytext,"%d",&yylval.entier); return NUM;}
'[a-zA-Z]' {(yylval.caractere = yytext[1]); return CARACTERE;}

[">", "<", "==", "<=", ">=", "!="] {(strcpy(yylval.comp,yytext)); return COMP;}
["+", "-"] {(yylval.caractere = yytext[0]); return ADDSUB;}
["*","/","%"] {(yylval.caractere = yytext[0]); return DIVSTAR;}


["&&", "||"] {strcpy(yylval.bool, yytext); return BOPE;}
[a-z]+ {strcpy(*(&yylval.ident), yytext); return IDENT;}
. return yytext[0];
%%
