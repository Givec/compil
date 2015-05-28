%{
#include "src/tcompil.h"

%}
%%
[ \t\n]+ ;
[0-9]+ {sscanf(yytext,"%d",&yylval.entier); return NUM;}
"if" {return IF;}
"else" {return ELSE;}
"print" {return PRINT;}
"main" {return MAIN;}
"while" {return WHILE;}
"void" {yylval.string = (char*)malloc(sizeof(char)*strlen(yytext)); sscanf(yytext, "%s", yylval.string); return VOID;}
"entier" {yylval.string = (char*)malloc(sizeof(char)*strlen(yytext)); sscanf(yytext, "%s", yylval.string);return ENTIER; }
"var" {return VAR;}
"const" {return CONST;}
"return" {return RETURN;}
[a-zA-Z_][a-zA-Z_0-9]* { yylval.string = (char*)malloc(sizeof(char)*strlen(yytext)); sscanf(yytext, "%s", yylval.string); return IDENT;}
"+"|"-" {sscanf(yytext, "%c", &yylval.car); return ADDSUB;} 
"<"|">"|">="|"<="|"=="|"!=" {yylval.string = (char*)malloc(sizeof(char)*strlen(yytext));sscanf (yytext, "%s", yylval.string); return COMP;}
"*" {return STAR;}
"/"|"%" {sscanf(yytext, "%c", &yylval.car); return DIV;}
"&" {return ADR;}
"=" {return EGAL;}
";" {return PV;}
"," {return VRG;}
"(" {return LPAR;}
")" {return RPAR;}
"{" {return LACC;}
"}" {return RACC;}
"[" {return LSQB;}
"]" {return RSQB;}


. return yytext[0];
%%
