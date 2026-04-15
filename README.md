# CS327 Brolang Compiler - Assignment 4

This repository contains the Assignment 4 implementation for Intermediate Code Generation (ICG) in Three Address Code (TAC) quadruple format.

## What is implemented
- TAC quadruple IR (`op`, `arg1`, `arg2`, `result`)
- Arithmetic and unary expressions
- Assignments and compound assignments
- Control flow support:
  - `if`
  - `if-else`
  - `while`
  - `for`
- Label/goto based control-flow IR
- Error diagnostics with line numbers

## Main files
- `brolang_lexer_icg.l` - Lexer for ICG parser
- `brolang_parser_icg.y` - Yacc grammar with SDT actions
- `icg.h`, `icg.c` - IR data structures and printing
- `ASSIGNMENT4_REPORT.md` - Part-wise completion report
- `ASSIGNMENT4_10_EXAMPLES.md` - 10 required code-generation examples

## Testcases
- `testcases/valid/` - 10 valid programs
- `testcases/invalid/` - invalid programs for diagnostics

## Build
```bash
make clean
make icg
```

## Run
Single file:
```bash
./brolang_parser_icg testcases/valid/test01_arithmetic.bro
```

All valid files:
```bash
for f in testcases/valid/*.bro; do ./brolang_parser_icg "$f"; done
```

All invalid files:
```bash
for f in testcases/invalid/*.bro; do ./brolang_parser_icg "$f"; done
```

## Output artifacts
Generated outputs for each testcase are saved in:
- `assignment4_outputs/`

These outputs are also compiled in:
- `ASSIGNMENT4_10_EXAMPLES.md`
