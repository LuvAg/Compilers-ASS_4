%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "brolang_parser.tab.h"

int line_num = 1;

%}

%option noinput nounput

%%

hibro { return HIBRO; }
byebro { return BYEBRO; }
bro { return BRO; }
pakka { return PAKKA; }
num { return NUM; }
str { return STR; }
bool { return BOOL; }
nalla { return NALLA; }
sahi { return SAHI; }
galat { return GALAT; }
nil { return NIL; }
bolbro { return BOLBRO; }
broassert { return BROASSERT; }
agarbro { return AGARBRO; }
naitobro { return NAITOBRO; }
warnabro { return WARNABRO; }
jabtakbro { return JABTAKBRO; }
baskarbro { return BASKARBRO; }
agladehbro { return AGLADEHBRO; }

"+=" { return ADD_ASSIGN; }
"-=" { return SUB_ASSIGN; }
"*=" { return MUL_ASSIGN; }
"/=" { return DIV_ASSIGN; }
"==" { return EQ; }
"!=" { return NEQ; }
"<=" { return LE; }
">=" { return GE; }
"=" { return ASSIGN; }
"+" { return PLUS; }
"-" { return MINUS; }
"*" { return MUL; }
"/" { return DIV; }

";" { return SEMICOLON; }
"," { return COMMA; }
"(" { return LPAREN; }
")" { return RPAREN; }
"{" { return LBRACE; }
"}" { return RBRACE; }
"<" { return LT; }
">" { return GT; }

[0-9]+(\.[0-9]+)? { yylval.str = strdup(yytext); return NUMBER_LITERAL; }
\"([^\\\"]|\\.)*\" { yylval.str = strdup(yytext); return STRING_LITERAL; }
\'([^\\\']|\\.)*\' { yylval.str = strdup(yytext); return STRING_LITERAL; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }

"//"[^\n]* { }
[ \t\r]+ { }
\n { line_num++; }

. { fprintf(stderr, "Lexical Error: Unknown token '%s' at line %d\n", yytext, line_num); return -1; }

%%

int yywrap() { return 1; }
