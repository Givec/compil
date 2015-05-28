%{
include <string.h>
%}
%%
[ \t\n]+ ;
/*2 types reserves, soit "entier" soit "caractere"*/
"entier" {strcpy(*(&yylval.type), yytext); return TYPE;}
"caractere" {strcpy(*(&yylval.type), yytext); return TYPE;}


[0-9]+ {sscanf(yytext,"%d",&yylval.entier); return NUM;}
[\'a-zA-Z\'] {(yylval.caractere = yytext[1]); return CARACTERE;}
"const" {return CONST;}


[">", "<", "==", "<=", ">=", "!="] {(strcpy(yylval.comp,yytext)); return COMP;}
["+", "-"] {(yylval.caractere = yytext[0]); return ADDSUB;}
["*","/","%"] {(yylval.caractere = yytext[0]); return DIVSTAR;}


["&&", "||"] {strcpy(yylval.bool, yytext); return BOPE;}
"!" {(yylval.caractere = yytext[0]); return NEGATION;}


"=" {return EGAL;}
";" {return PV;}
"," {return VRG;}
"(" {return LPAR;}
")" {return RPAR;}
"{" {return LACC;}
"}" {return RACC;}
"[" {return LSQB;}
"]" {return RSQB;}


"print" {return PRINT;}


[a-z]+ {strcpy(*(&yylval.ident), yytext); return IDENT;}
. return yytext[0];
%%
