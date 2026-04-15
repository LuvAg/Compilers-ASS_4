# CS327 Assignment 4 - 10 Code Generation Examples

Each example includes the Brolang source and the generated TAC quadruples.

## test01_arithmetic

### Source
```brolang
hibro
bro num a = 5;
bro num b = 3;
bro num c = 2;
bro num x = a + b * c;
bolbro x;
byebro
```

### Generated Output
```text
════════════════════════════════════════════════════════════════
  BROLANG INTERMEDIATE CODE GENERATOR - CS327 Assignment #4
════════════════════════════════════════════════════════════════

✓ Parsing and code generation successful!

========================================
        SOURCE PROGRAM INPUT
========================================
hibro
bro num a = 5;
bro num b = 3;
bro num c = 2;
bro num x = a + b * c;
bolbro x;
byebro


========================================
   GENERATED INTERMEDIATE CODE (TAC)   
========================================

#     | OP           | ARG1         | ARG2         | RESULT      
------|--------------|--------------|--------------|---------------
0     | =            | 5            |              | a           
1     | =            | 3            |              | b           
2     | =            | 2            |              | c           
3     | *            | b            | c            | t1          
4     | +            | a            | t1           | t2          
5     | =            | t2           |              | x           
6     | print        | x            |              |             


========================================
         IR GENERATION STATISTICS
========================================
Total Quadruples Generated: 7
Temporary Variables Used:   2
Labels Generated:           0

════════════════════════════════════════════════════════════════
Status: ✓ INTERMEDIATE CODE GENERATION COMPLETE
════════════════════════════════════════════════════════════════

```

## test02_unary_minus_quad

### Source
```brolang
hibro
bro num a = 0;
bro num b = 7;
bro num c = 4;
a = b * -c + b * -c;
bolbro a;
byebro
```

### Generated Output
```text
════════════════════════════════════════════════════════════════
  BROLANG INTERMEDIATE CODE GENERATOR - CS327 Assignment #4
════════════════════════════════════════════════════════════════

✓ Parsing and code generation successful!

========================================
        SOURCE PROGRAM INPUT
========================================
hibro
bro num a = 0;
bro num b = 7;
bro num c = 4;
a = b * -c + b * -c;
bolbro a;
byebro


========================================
   GENERATED INTERMEDIATE CODE (TAC)   
========================================

#     | OP           | ARG1         | ARG2         | RESULT      
------|--------------|--------------|--------------|---------------
0     | =            | 0            |              | a           
1     | =            | 7            |              | b           
2     | =            | 4            |              | c           
3     | minus        | c            |              | t1          
4     | *            | b            | t1           | t2          
5     | minus        | c            |              | t3          
6     | *            | b            | t3           | t4          
7     | +            | t2           | t4           | t5          
8     | =            | t5           |              | a           
9     | print        | a            |              |             


========================================
         IR GENERATION STATISTICS
========================================
Total Quadruples Generated: 10
Temporary Variables Used:   5
Labels Generated:           0

════════════════════════════════════════════════════════════════
Status: ✓ INTERMEDIATE CODE GENERATION COMPLETE
════════════════════════════════════════════════════════════════

```

## test03_compound_assign

### Source
```brolang
hibro
bro num x = 10;
bro num y = 5;
x += y;
x -= 2;
x *= 3;
x /= 2;
bolbro x;
byebro
```

### Generated Output
```text
════════════════════════════════════════════════════════════════
  BROLANG INTERMEDIATE CODE GENERATOR - CS327 Assignment #4
════════════════════════════════════════════════════════════════

✓ Parsing and code generation successful!

========================================
        SOURCE PROGRAM INPUT
========================================
hibro
bro num x = 10;
bro num y = 5;
x += y;
x -= 2;
x *= 3;
x /= 2;
bolbro x;
byebro


========================================
   GENERATED INTERMEDIATE CODE (TAC)   
========================================

#     | OP           | ARG1         | ARG2         | RESULT      
------|--------------|--------------|--------------|---------------
0     | =            | 10           |              | x           
1     | =            | 5            |              | y           
2     | +            | x            | y            | t1          
3     | =            | t1           |              | x           
4     | -            | x            | 2            | t2          
5     | =            | t2           |              | x           
6     | *            | x            | 3            | t3          
7     | =            | t3           |              | x           
8     | /            | x            | 2            | t4          
9     | =            | t4           |              | x           
10    | print        | x            |              |             


========================================
         IR GENERATION STATISTICS
========================================
Total Quadruples Generated: 11
Temporary Variables Used:   4
Labels Generated:           0

════════════════════════════════════════════════════════════════
Status: ✓ INTERMEDIATE CODE GENERATION COMPLETE
════════════════════════════════════════════════════════════════

```

## test04_if_only

### Source
```brolang
hibro
bro num x = 8;
agarbro (x > 5) {
  bolbro x;
}
byebro
```

### Generated Output
```text
════════════════════════════════════════════════════════════════
  BROLANG INTERMEDIATE CODE GENERATOR - CS327 Assignment #4
════════════════════════════════════════════════════════════════

✓ Parsing and code generation successful!

========================================
        SOURCE PROGRAM INPUT
========================================
hibro
bro num x = 8;
agarbro (x > 5) {
  bolbro x;
}
byebro


========================================
   GENERATED INTERMEDIATE CODE (TAC)   
========================================

#     | OP           | ARG1         | ARG2         | RESULT      
------|--------------|--------------|--------------|---------------
0     | =            | 8            |              | x           
1     | >            | x            | 5            | t1          
2     | ifFalse      | t1           |              | L1          
3     | print        | x            |              |             
4     | label        | L1           |              |             


========================================
         IR GENERATION STATISTICS
========================================
Total Quadruples Generated: 5
Temporary Variables Used:   1
Labels Generated:           1

════════════════════════════════════════════════════════════════
Status: ✓ INTERMEDIATE CODE GENERATION COMPLETE
════════════════════════════════════════════════════════════════

```

## test05_if_else

### Source
```brolang
hibro
bro num x = 2;
agarbro (x > 5) {
  bolbro 100;
}
warnabro {
  bolbro 200;
}
byebro
```

### Generated Output
```text
════════════════════════════════════════════════════════════════
  BROLANG INTERMEDIATE CODE GENERATOR - CS327 Assignment #4
════════════════════════════════════════════════════════════════

✓ Parsing and code generation successful!

========================================
        SOURCE PROGRAM INPUT
========================================
hibro
bro num x = 2;
agarbro (x > 5) {
  bolbro 100;
}
warnabro {
  bolbro 200;
}
byebro


========================================
   GENERATED INTERMEDIATE CODE (TAC)   
========================================

#     | OP           | ARG1         | ARG2         | RESULT      
------|--------------|--------------|--------------|---------------
0     | =            | 2            |              | x           
1     | >            | x            | 5            | t1          
2     | ifFalse      | t1           |              | L1          
3     | print        | 100          |              |             
4     | goto         |              |              | L2          
5     | label        | L1           |              |             
6     | print        | 200          |              |             
7     | label        | L2           |              |             


========================================
         IR GENERATION STATISTICS
========================================
Total Quadruples Generated: 8
Temporary Variables Used:   1
Labels Generated:           2

════════════════════════════════════════════════════════════════
Status: ✓ INTERMEDIATE CODE GENERATION COMPLETE
════════════════════════════════════════════════════════════════

```

## test06_while_loop

### Source
```brolang
hibro
bro num i = 0;
jabtakbro (i < 3) {
  bolbro i;
  i += 1;
}
byebro
```

### Generated Output
```text
════════════════════════════════════════════════════════════════
  BROLANG INTERMEDIATE CODE GENERATOR - CS327 Assignment #4
════════════════════════════════════════════════════════════════

✓ Parsing and code generation successful!

========================================
        SOURCE PROGRAM INPUT
========================================
hibro
bro num i = 0;
jabtakbro (i < 3) {
  bolbro i;
  i += 1;
}
byebro


========================================
   GENERATED INTERMEDIATE CODE (TAC)   
========================================

#     | OP           | ARG1         | ARG2         | RESULT      
------|--------------|--------------|--------------|---------------
0     | =            | 0            |              | i           
1     | label        | L1           |              |             
2     | <            | i            | 3            | t1          
3     | ifFalse      | t1           |              | L2          
4     | print        | i            |              |             
5     | +            | i            | 1            | t2          
6     | =            | t2           |              | i           
7     | goto         |              |              | L1          
8     | label        | L2           |              |             


========================================
         IR GENERATION STATISTICS
========================================
Total Quadruples Generated: 9
Temporary Variables Used:   2
Labels Generated:           2

════════════════════════════════════════════════════════════════
Status: ✓ INTERMEDIATE CODE GENERATION COMPLETE
════════════════════════════════════════════════════════════════

```

## test07_for_loop

### Source
```brolang
hibro
bro num i = 0;
forbro (i = 0; i < 4; i += 1) {
  bolbro i;
}
byebro
```

### Generated Output
```text
════════════════════════════════════════════════════════════════
  BROLANG INTERMEDIATE CODE GENERATOR - CS327 Assignment #4
════════════════════════════════════════════════════════════════

✓ Parsing and code generation successful!

========================================
        SOURCE PROGRAM INPUT
========================================
hibro
bro num i = 0;
forbro (i = 0; i < 4; i += 1) {
  bolbro i;
}
byebro


========================================
   GENERATED INTERMEDIATE CODE (TAC)   
========================================

#     | OP           | ARG1         | ARG2         | RESULT      
------|--------------|--------------|--------------|---------------
0     | =            | 0            |              | i           
1     | =            | 0            |              | i           
2     | label        | L1           |              |             
3     | <            | i            | 4            | t1          
4     | ifFalse      | t1           |              | L2          
5     | print        | i            |              |             
6     | +            | i            | 1            | t2          
7     | =            | t2           |              | i           
8     | goto         |              |              | L1          
9     | label        | L2           |              |             


========================================
         IR GENERATION STATISTICS
========================================
Total Quadruples Generated: 10
Temporary Variables Used:   2
Labels Generated:           2

════════════════════════════════════════════════════════════════
Status: ✓ INTERMEDIATE CODE GENERATION COMPLETE
════════════════════════════════════════════════════════════════

```

## test08_nested_control

### Source
```brolang
hibro
bro num i = 0;
jabtakbro (i < 3) {
  agarbro (i == 1) {
    bolbro 999;
  }
  warnabro {
    bolbro i;
  }
  i += 1;
}
byebro
```

### Generated Output
```text
════════════════════════════════════════════════════════════════
  BROLANG INTERMEDIATE CODE GENERATOR - CS327 Assignment #4
════════════════════════════════════════════════════════════════

✓ Parsing and code generation successful!

========================================
        SOURCE PROGRAM INPUT
========================================
hibro
bro num i = 0;
jabtakbro (i < 3) {
  agarbro (i == 1) {
    bolbro 999;
  }
  warnabro {
    bolbro i;
  }
  i += 1;
}
byebro


========================================
   GENERATED INTERMEDIATE CODE (TAC)   
========================================

#     | OP           | ARG1         | ARG2         | RESULT      
------|--------------|--------------|--------------|---------------
0     | =            | 0            |              | i           
1     | label        | L1           |              |             
2     | <            | i            | 3            | t1          
3     | ifFalse      | t1           |              | L2          
4     | ==           | i            | 1            | t2          
5     | ifFalse      | t2           |              | L3          
6     | print        | 999          |              |             
7     | goto         |              |              | L4          
8     | label        | L3           |              |             
9     | print        | i            |              |             
10    | label        | L4           |              |             
11    | +            | i            | 1            | t3          
12    | =            | t3           |              | i           
13    | goto         |              |              | L1          
14    | label        | L2           |              |             


========================================
         IR GENERATION STATISTICS
========================================
Total Quadruples Generated: 15
Temporary Variables Used:   3
Labels Generated:           4

════════════════════════════════════════════════════════════════
Status: ✓ INTERMEDIATE CODE GENERATION COMPLETE
════════════════════════════════════════════════════════════════

```

## test09_assert_relations

### Source
```brolang
hibro
bro num a = 9;
bro num b = 4;
broassert (a >= b);
broassert (a != b);
bolbro a, b;
byebro
```

### Generated Output
```text
════════════════════════════════════════════════════════════════
  BROLANG INTERMEDIATE CODE GENERATOR - CS327 Assignment #4
════════════════════════════════════════════════════════════════

✓ Parsing and code generation successful!

========================================
        SOURCE PROGRAM INPUT
========================================
hibro
bro num a = 9;
bro num b = 4;
broassert (a >= b);
broassert (a != b);
bolbro a, b;
byebro


========================================
   GENERATED INTERMEDIATE CODE (TAC)   
========================================

#     | OP           | ARG1         | ARG2         | RESULT      
------|--------------|--------------|--------------|---------------
0     | =            | 9            |              | a           
1     | =            | 4            |              | b           
2     | >=           | a            | b            | t1          
3     | assert       | t1           |              |             
4     | !=           | a            | b            | t2          
5     | assert       | t2           |              |             
6     | print        | a,b          |              |             


========================================
         IR GENERATION STATISTICS
========================================
Total Quadruples Generated: 7
Temporary Variables Used:   2
Labels Generated:           0

════════════════════════════════════════════════════════════════
Status: ✓ INTERMEDIATE CODE GENERATION COMPLETE
════════════════════════════════════════════════════════════════

```

## test10_strings_bool

### Source
```brolang
hibro
bro str msg = "hello";
bro bool ok = sahi;
bolbro msg, ok;
byebro
```

### Generated Output
```text
════════════════════════════════════════════════════════════════
  BROLANG INTERMEDIATE CODE GENERATOR - CS327 Assignment #4
════════════════════════════════════════════════════════════════

✓ Parsing and code generation successful!

========================================
        SOURCE PROGRAM INPUT
========================================
hibro
bro str msg = "hello";
bro bool ok = sahi;
bolbro msg, ok;
byebro


========================================
   GENERATED INTERMEDIATE CODE (TAC)   
========================================

#     | OP           | ARG1         | ARG2         | RESULT      
------|--------------|--------------|--------------|---------------
0     | =            | "hello"      |              | msg         
1     | =            | sahi         |              | ok          
2     | print        | msg,ok       |              |             


========================================
         IR GENERATION STATISTICS
========================================
Total Quadruples Generated: 3
Temporary Variables Used:   0
Labels Generated:           0

════════════════════════════════════════════════════════════════
Status: ✓ INTERMEDIATE CODE GENERATION COMPLETE
════════════════════════════════════════════════════════════════

```

