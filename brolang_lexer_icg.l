%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "brolang_parser_icg.tab.h"

int line_num = 1;
int lexical_error_reported = 0;

static int report_unsupported_construct(const char* kw) {
	lexical_error_reported = 1;
	fprintf(stderr,
			"Unsupported construct at line %d: '%s' is not supported in Assignment 4 ICG\n",
			line_num,
			kw);
	return -1;
}

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
forbro { return FORBRO; }
baskarbro { return BASKARBRO; }
agladehbro { return AGLADEHBRO; }

switchbro { return report_unsupported_construct("switchbro"); }
casebro { return report_unsupported_construct("casebro"); }
defaultbro { return report_unsupported_construct("defaultbro"); }
dobro { return report_unsupported_construct("dobro"); }
functionbro { return report_unsupported_construct("functionbro"); }
returnbro { return report_unsupported_construct("returnbro"); }

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

. {
	lexical_error_reported = 1;
	fprintf(stderr, "Lexical Error at line %d: unknown token '%s'\n", line_num, yytext);
	return -1;
}

%%

int yywrap() { return 1; }
