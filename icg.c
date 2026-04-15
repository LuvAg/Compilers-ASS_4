#include "icg.h"
#include <stdarg.h>

/* Global IR instance */
IRCode* ir = NULL;

/* Initialize IR */
IRCode* ir_init(void) {
    ir = (IRCode*)malloc(sizeof(IRCode));
    ir->quads = (Quadruple*)malloc(sizeof(Quadruple) * 1000);
    ir->count = 0;
    ir->capacity = 1000;
    ir->temp_count = 0;
    ir->label_count = 0;
    return ir;
}

/* Emit a quadruple */
void ir_emit(const char* op, const char* arg1, const char* arg2, const char* result) {
    if (!ir) ir_init();
    
    if (ir->count >= ir->capacity) {
        ir->capacity *= 2;
        ir->quads = (Quadruple*)realloc(ir->quads, sizeof(Quadruple) * ir->capacity);
    }
    
    Quadruple* q = &ir->quads[ir->count];
    q->op = (op ? strdup(op) : NULL);
    q->arg1 = (arg1 ? strdup(arg1) : NULL);
    q->arg2 = (arg2 ? strdup(arg2) : NULL);
    q->result = (result ? strdup(result) : NULL);
    
    ir->count++;
}

/* Generate a temporary variable */
char* ir_new_temp(void) {
    if (!ir) ir_init();
    
    char* temp = (char*)malloc(20);
    snprintf(temp, 20, "t%d", ++ir->temp_count);
    return temp;
}

/* Generate a label */
char* ir_new_label(void) {
    if (!ir) ir_init();
    
    char* label = (char*)malloc(20);
    snprintf(label, 20, "L%d", ++ir->label_count);
    return label;
}

/* Print IR in tabular format */
void ir_print(FILE* out) {
    if (!ir || ir->count == 0) {
        fprintf(out, "No intermediate code generated.\n");
        return;
    }
    
    fprintf(out, "\n");
    fprintf(out, "========================================\n");
    fprintf(out, "   GENERATED INTERMEDIATE CODE (TAC)   \n");
    fprintf(out, "========================================\n");
    fprintf(out, "\n");
    
    /* Print header */
    fprintf(out, "%-5s | %-12s | %-12s | %-12s | %-12s\n", "#", "OP", "ARG1", "ARG2", "RESULT");
    fprintf(out, "------|--------------|--------------|--------------|---------------\n");
    
    /* Print quadruples */
    for (int i = 0; i < ir->count; i++) {
        Quadruple* q = &ir->quads[i];
        
        char arg1_buf[15] = "-";
        char arg2_buf[15] = "-";
        char result_buf[15] = "-";
        
        if (q->arg1) {
            strncpy(arg1_buf, q->arg1, 12);
            arg1_buf[12] = '\0';
        }
        if (q->arg2) {
            strncpy(arg2_buf, q->arg2, 12);
            arg2_buf[12] = '\0';
        }
        if (q->result) {
            strncpy(result_buf, q->result, 12);
            result_buf[12] = '\0';
        }
        
        fprintf(out, "%-5d | %-12s | %-12s | %-12s | %-12s\n", 
                i, q->op ? q->op : "-", arg1_buf, arg2_buf, result_buf);
    }
    
    fprintf(out, "\n");
}

/* Print source program */
void ir_print_source(FILE* out, const char* source) {
    fprintf(out, "========================================\n");
    fprintf(out, "        SOURCE PROGRAM INPUT\n");
    fprintf(out, "========================================\n");
    fprintf(out, "%s\n", source);
}

/* Print IR statistics */
void ir_print_stats(FILE* out) {
    if (!ir) {
        fprintf(out, "No IR generated.\n");
        return;
    }
    
    fprintf(out, "\n");
    fprintf(out, "========================================\n");
    fprintf(out, "         IR GENERATION STATISTICS\n");
    fprintf(out, "========================================\n");
    fprintf(out, "Total Quadruples Generated: %d\n", ir->count);
    fprintf(out, "Temporary Variables Used:   %d\n", ir->temp_count);
    fprintf(out, "Labels Generated:           %d\n", ir->label_count);
    fprintf(out, "\n");
}

/* Free IR */
void ir_free(void) {
    if (!ir) return;
    
    for (int i = 0; i < ir->count; i++) {
        if (ir->quads[i].op) free(ir->quads[i].op);
        if (ir->quads[i].arg1) free(ir->quads[i].arg1);
        if (ir->quads[i].arg2) free(ir->quads[i].arg2);
        if (ir->quads[i].result) free(ir->quads[i].result);
    }
    
    free(ir->quads);
    free(ir);
    ir = NULL;
}
