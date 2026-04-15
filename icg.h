#ifndef ICG_H
#define ICG_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Three Address Code (TAC) Quadruple Structure */
typedef struct {
    char* op;           /* operation: +, -, *, /, =, <, >, <=, >=, ==, !=, label, goto, if, etc. */
    char* arg1;         /* first argument (variable or constant) */
    char* arg2;         /* second argument (variable or constant) */
    char* result;       /* result variable or label */
} Quadruple;

/* IR Code List */
typedef struct {
    Quadruple* quads;   /* array of quadruples */
    int count;          /* number of quadruples */
    int capacity;       /* capacity of array */
    int temp_count;     /* temporary variable counter */
    int label_count;    /* label counter */
} IRCode;

/* Global IR instance */
extern IRCode* ir;

/* Function Prototypes */

/* Initialize IR */
IRCode* ir_init(void);

/* Emit a quadruple */
void ir_emit(const char* op, const char* arg1, const char* arg2, const char* result);

/* Generate a temporary variable */
char* ir_new_temp(void);

/* Generate a label */
char* ir_new_label(void);

/* Print IR in tabular format */
void ir_print(FILE* out);

/* Print source program */
void ir_print_source(FILE* out, const char* source);

/* Print IR statistics */
void ir_print_stats(FILE* out);

/* Free IR */
void ir_free(void);

#endif /* ICG_H */
