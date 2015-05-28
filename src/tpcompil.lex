%{
#include "src/tpcompil.h"
%}
%%
[ \t\n]+ ;
"entier" {strcpy(*(&yylval.type), yytext); return TYPE;}
"caractere" {strcpy(*(&yylval.type), yytext); return TYPE;}
[0-9]+ {sscanf(yytext,"%d",&yylval.entier); return NUM;}
";" {return PV;}
"const" {return CONST;}
"," {return VRG;}
"=" {return EGAL;}
["+", "-"] {(yylval.caractere = yytext[0]); return ADDSUB;}
"print" {return PRINT;}
[a-z]+ {strcpy(*(&yylval.ident), yytext); return IDENT;}
. {(yylval.caractere = yytext[0]); return CARACTERE;}
%%
