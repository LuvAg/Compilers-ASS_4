%code requires {
#include "icg.h"
#include <string.h>
}

%define parse.error verbose

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "icg.h"

extern int line_num;
extern int lexical_error_reported;
extern FILE* yyin;
extern IRCode* ir;
extern char* yytext;

void yyerror(const char* msg);
int yylex(void);

static int error_count = 0;
static char source_buffer[10000] = "";
static int source_pos = 0;

typedef struct {
    char* false_label;
    char* end_label;
} IfContext;

typedef struct {
    char* start_label;
    char* exit_label;
} LoopContext;

typedef struct {
    char* update_lhs;
    char* update_op;
    char* update_rhs;
    char* loop_start;
    char* loop_exit;
} ForContext;

static IfContext if_stack[64];
static int if_top = -1;

static LoopContext while_stack[64];
static int while_top = -1;

static ForContext for_stack[64];
static int for_top = -1;

/* Helper function to get expression variable name */
char* expr_to_string(char* expr);

%}

%union {
    char* str;
}

/* Terminal Tokens */
%token HIBRO BYEBRO BRO PAKKA NUM STR BOOL NALLA
%token SAHI GALAT NIL BOLBRO BROASSERT AGARBRO NAITOBRO WARNABRO
%token JABTAKBRO FORBRO BASKARBRO AGLADEHBRO
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN
%token EQ NEQ LE GE LT GT
%token ASSIGN PLUS MINUS MUL DIV
%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE

%token <str> IDENTIFIER NUMBER_LITERAL STRING_LITERAL

/* Non-terminals */
%type <str> program stmts stmt block expr_list expr type_name assign_op
%type <str> for_atom if_prefix

/* Conflict expectation */
%expect 0

/* Precedence */
%left COMMA
%left LT GT LE GE EQ NEQ
%left PLUS MINUS
%left MUL DIV
%nonassoc LOWER_THAN_WARNABRO
%nonassoc WARNABRO

%%

program : HIBRO stmts BYEBRO
        {
            $$ = "program";
        }
        ;

stmts   : /* empty */
        {
            $$ = "";
        }
        | stmts stmt
        {
            $$ = "";
        }
        ;

stmt    : BRO type_name IDENTIFIER ASSIGN expr SEMICOLON
        {
            /* Variable declaration with initialization */
            ir_emit("=", $5, "", $3);
            $$ = "";
        }
        | BRO type_name IDENTIFIER SEMICOLON
        {
            /* Variable declaration without initialization */
            $$ = "";
        }
        | PAKKA BRO type_name IDENTIFIER ASSIGN expr SEMICOLON
        {
            /* Constant declaration */
            ir_emit("=", $6, "", $4);
            $$ = "";
        }
        | IDENTIFIER assign_op expr SEMICOLON
        {
            /* Assignment statement */
            if (strcmp($2, "=") == 0) {
                ir_emit("=", $3, "", $1);
            } else if (strcmp($2, "+=") == 0) {
                char* temp = ir_new_temp();
                ir_emit("+", $1, $3, temp);
                ir_emit("=", temp, "", $1);
                free(temp);
            } else if (strcmp($2, "-=") == 0) {
                char* temp = ir_new_temp();
                ir_emit("-", $1, $3, temp);
                ir_emit("=", temp, "", $1);
                free(temp);
            } else if (strcmp($2, "*=") == 0) {
                char* temp = ir_new_temp();
                ir_emit("*", $1, $3, temp);
                ir_emit("=", temp, "", $1);
                free(temp);
            } else if (strcmp($2, "/=") == 0) {
                char* temp = ir_new_temp();
                ir_emit("/", $1, $3, temp);
                ir_emit("=", temp, "", $1);
                free(temp);
            }
            $$ = "";
        }
        | BOLBRO expr_list SEMICOLON
        {
            /* Print statement */
            ir_emit("print", $2, "", "");
            $$ = "";
        }
        | BROASSERT LPAREN expr RPAREN SEMICOLON
        {
            /* Assert statement */
            ir_emit("assert", $3, "", "");
            $$ = "";
        }
        | BASKARBRO SEMICOLON
        {
            /* Break statement */
            ir_emit("break", "", "", "");
            $$ = "";
        }
        | AGLADEHBRO SEMICOLON
        {
            /* Continue statement */
            ir_emit("continue", "", "", "");
            $$ = "";
        }
                | if_prefix block %prec LOWER_THAN_WARNABRO
        {
            /* If statement */
            IfContext ctx = if_stack[if_top--];
            ir_emit("label", ctx.false_label, "", "");
            free(ctx.false_label);
            $$ = "";
        }
                | if_prefix block WARNABRO
        {
            /* Jump over else block, then place else label */
            IfContext* ctx = &if_stack[if_top];
                        if (!ctx->end_label) {
                                ctx->end_label = ir_new_label();
                        }
            ir_emit("goto", "", "", ctx->end_label);
            ir_emit("label", ctx->false_label, "", "");
        }
          block
        {
            /* If-Else statement */
            IfContext ctx = if_stack[if_top--];
            ir_emit("label", ctx.end_label, "", "");
            free(ctx.false_label);
            free(ctx.end_label);
            $$ = "";
        }
        | JABTAKBRO LPAREN
        {
            LoopContext ctx;
            ctx.start_label = ir_new_label();
            ctx.exit_label = ir_new_label();
            while_stack[++while_top] = ctx;

            ir_emit("label", ctx.start_label, "", "");
        }
          expr RPAREN
        {
            ir_emit("ifFalse", $4, "", while_stack[while_top].exit_label);
        }
          block
        {
            /* While loop */
            LoopContext ctx = while_stack[while_top--];
            ir_emit("goto", "", "", ctx.start_label);
            ir_emit("label", ctx.exit_label, "", "");
            free(ctx.start_label);
            free(ctx.exit_label);
            $$ = "";
        }
        | FORBRO LPAREN IDENTIFIER ASSIGN expr SEMICOLON
        {
            /* for-init: i = expr */
            ir_emit("=", $5, "", $3);

            ForContext ctx;
            ctx.update_lhs = NULL;
            ctx.update_op = NULL;
            ctx.update_rhs = NULL;
            ctx.loop_start = ir_new_label();
            ctx.loop_exit = ir_new_label();
            for_stack[++for_top] = ctx;

            ir_emit("label", ctx.loop_start, "", "");
        }
          expr SEMICOLON IDENTIFIER assign_op for_atom RPAREN
        {
            /* for-condition + capture for-update */
            ForContext* ctx = &for_stack[for_top];
            ir_emit("ifFalse", $8, "", ctx->loop_exit);

            ctx->update_lhs = strdup($10);
            ctx->update_op = strdup($11);
            ctx->update_rhs = strdup($12);
        }
          block
        {
            /* for-update */
            ForContext ctx = for_stack[for_top--];

            if (strcmp(ctx.update_op, "=") == 0) {
                ir_emit("=", ctx.update_rhs, "", ctx.update_lhs);
            } else {
                char* temp = ir_new_temp();
                if (strcmp(ctx.update_op, "+=") == 0) {
                    ir_emit("+", ctx.update_lhs, ctx.update_rhs, temp);
                } else if (strcmp(ctx.update_op, "-=") == 0) {
                    ir_emit("-", ctx.update_lhs, ctx.update_rhs, temp);
                } else if (strcmp(ctx.update_op, "*=") == 0) {
                    ir_emit("*", ctx.update_lhs, ctx.update_rhs, temp);
                } else if (strcmp(ctx.update_op, "/=") == 0) {
                    ir_emit("/", ctx.update_lhs, ctx.update_rhs, temp);
                }
                ir_emit("=", temp, "", ctx.update_lhs);
                free(temp);
            }

            ir_emit("goto", "", "", ctx.loop_start);
            ir_emit("label", ctx.loop_exit, "", "");

            free(ctx.update_lhs);
            free(ctx.update_op);
            free(ctx.update_rhs);
            free(ctx.loop_start);
            free(ctx.loop_exit);
            $$ = "";
        }
        ;

if_prefix : AGARBRO LPAREN expr RPAREN
        {
            IfContext ctx;
            ctx.false_label = ir_new_label();
            ctx.end_label = NULL;
            if_stack[++if_top] = ctx;

            ir_emit("ifFalse", $3, "", ctx.false_label);
            $$ = "";
        }
        ;

for_atom : IDENTIFIER
        {
            $$ = $1;
        }
        | NUMBER_LITERAL
        {
            $$ = $1;
        }
        ;

type_name : NUM { $$ = "num"; }
        | STR { $$ = "str"; }
        | BOOL { $$ = "bool"; }
        | NALLA { $$ = "nalla"; }
        ;

assign_op : ASSIGN { $$ = "="; }
        | ADD_ASSIGN { $$ = "+="; }
        | SUB_ASSIGN { $$ = "-="; }
        | MUL_ASSIGN { $$ = "*="; }
        | DIV_ASSIGN { $$ = "/="; }
        ;

block   : LBRACE stmts RBRACE
        {
            $$ = "";
        }
        ;

expr_list : expr
        {
            $$ = $1;
        }
        | expr_list COMMA expr
        {
            /* Multiple expressions in print */
            static char buf[256];
            snprintf(buf, sizeof(buf), "%s,%s", $1, $3);
            $$ = buf;
        }
        ;

expr    : NUMBER_LITERAL
        {
            $$ = $1;
        }
        | STRING_LITERAL
        {
            $$ = $1;
        }
        | IDENTIFIER
        {
            $$ = $1;
        }
        | SAHI
        {
            static char buf[10];
            strcpy(buf, "sahi");
            $$ = buf;
        }
        | GALAT
        {
            static char buf[10];
            strcpy(buf, "galat");
            $$ = buf;
        }
        | NIL
        {
            static char buf[10];
            strcpy(buf, "nil");
            $$ = buf;
        }
        | expr PLUS expr
        {
            char* temp = ir_new_temp();
            ir_emit("+", $1, $3, temp);
            $$ = temp;
        }
        | expr MINUS expr
        {
            char* temp = ir_new_temp();
            ir_emit("-", $1, $3, temp);
            $$ = temp;
        }
        | expr MUL expr
        {
            char* temp = ir_new_temp();
            ir_emit("*", $1, $3, temp);
            $$ = temp;
        }
        | expr DIV expr
        {
            char* temp = ir_new_temp();
            ir_emit("/", $1, $3, temp);
            $$ = temp;
        }
        | expr EQ expr
        {
            char* temp = ir_new_temp();
            ir_emit("==", $1, $3, temp);
            $$ = temp;
        }
        | expr NEQ expr
        {
            char* temp = ir_new_temp();
            ir_emit("!=", $1, $3, temp);
            $$ = temp;
        }
        | expr LT expr
        {
            char* temp = ir_new_temp();
            ir_emit("<", $1, $3, temp);
            $$ = temp;
        }
        | expr GT expr
        {
            char* temp = ir_new_temp();
            ir_emit(">", $1, $3, temp);
            $$ = temp;
        }
        | expr LE expr
        {
            char* temp = ir_new_temp();
            ir_emit("<=", $1, $3, temp);
            $$ = temp;
        }
        | expr GE expr
        {
            char* temp = ir_new_temp();
            ir_emit(">=", $1, $3, temp);
            $$ = temp;
        }
        | MINUS expr
        {
            char* temp = ir_new_temp();
            ir_emit("minus", $2, "", temp);
            $$ = temp;
        }
        | LPAREN expr RPAREN
        {
            $$ = $2;
        }
        ;

%%

void yyerror(const char* msg) {
    if (lexical_error_reported) {
        lexical_error_reported = 0;
        error_count++;
        return;
    }

    error_count++;
    if (yytext && yytext[0] != '\0') {
        fprintf(stderr, "Syntax Error at line %d near '%s': %s\n", line_num, yytext, msg);
    } else {
        fprintf(stderr, "Syntax Error at line %d: %s\n", line_num, msg);
    }
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE* f = fopen(argv[1], "r");
    if (!f) {
        perror("fopen");
        return 1;
    }

    /* Read source file into buffer */
    int c;
    while ((c = fgetc(f)) != EOF && source_pos < (int)(sizeof(source_buffer) - 1)) {
        source_buffer[source_pos++] = c;
    }
    source_buffer[source_pos] = '\0';
    rewind(f);
    yyin = f;

    printf("════════════════════════════════════════════════════════════════\n");
    printf("  BROLANG INTERMEDIATE CODE GENERATOR - CS327 Assignment #4\n");
    printf("════════════════════════════════════════════════════════════════\n\n");

    if (yyparse() == 0 && error_count == 0) {
        printf("✓ Parsing and code generation successful!\n\n");

        /* Print source code */
        ir_print_source(stdout, source_buffer);

        /* Print generated IR */
        ir_print(stdout);

        /* Print statistics */
        ir_print_stats(stdout);

        printf("════════════════════════════════════════════════════════════════\n");
        printf("Status: ✓ INTERMEDIATE CODE GENERATION COMPLETE\n");
        printf("════════════════════════════════════════════════════════════════\n\n");

        ir_free();
    } else {
        printf("✗ Code generation failed with %d error(s)\n", error_count);
        if (ir) ir_free();
    }

    fclose(f);
    return error_count > 0 ? 1 : 0;
}
