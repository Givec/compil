%{
#include "src/tpcompil.h"
%}
%%
[ \t\n]+ ;
"entier" {strcpy(*(&yyval.type), yytext); return TYPE;}
"caractere" {strcpy(*(&yyval.type), yytext); return TYPE;}
[0-9]+ {sscanf(yytext,"%d",&yylval.entier); return NUM;}
";" {return PV;}
"const" {return CONST;}
"," {return VRG;}
"=" {return EGAL;}
["+", "-"] {{strcpy(*(&yyval.caractere), yytext); return ADDSUB;}
"print" {return PRINT;}
[a-z]+ {strcpy(*(&yylval.ident), yytext); return IDENT;}
[a-z] {strcpy(*(&yylval.caractere), yytext); return CARACTERE;}
%%
