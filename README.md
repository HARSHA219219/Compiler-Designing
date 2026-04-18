# CS327 Compilers Lab Assignment 4

## Intermediate Code Generation Using Lex and Yacc

**Course:** CS327 Compilers  
**Assignment:** Intermediate Code Generation  
**Instructor:** Shouvick Mondal  
**Semester:** January-May 2026  
**Submission Date:** April 18, 2026  

**Team Members**

| Member | Roll No. | Contribution Area |
|---|---|---|
| Member 1 | `[Add Roll No.]` | Lexical analyzer and token design |
| Member 2 | `[Add Roll No.]` | Grammar design and parsing |
| Member 3 | `[Add Roll No.]` | TAC generation and control flow translation |
| Member 4 | `[Add Roll No.]` | Testing, diagnostics, and documentation |

## 1. Objective

The objective of this assignment is to design a MiniC compiler front end that translates source programs into **Three Address Code (TAC)** represented in **quadruple format**. The implementation uses **Lex/Flex** for lexical analysis and **Yacc/Bison** for syntax analysis and syntax-directed translation. The system supports arithmetic expressions, assignment statements, temporary variable generation, conditional statements, iterative statements, and label-based control flow generation. The compiler also reports meaningful diagnostics for malformed input without crashing.

## 2. System Overview

The implemented compiler follows the classical front-end pipeline:

1. **Lexical Analysis**
   - Implemented in [minic.l](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/minic.l).
   - Converts the source program into a stream of tokens such as identifiers, keywords, literals, operators, and punctuators.
   - Tracks line and column positions for error reporting.

2. **Parsing**
   - Implemented in [parser_resolved.y](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/parser_resolved.y).
   - Validates the token stream against the MiniC grammar.
   - Uses structured grammar rules for declarations, expressions, selection statements, loops, and returns.

3. **Intermediate Code Generation**
   - Integrated directly into Yacc semantic actions using **Syntax Directed Translation (SDT)**.
   - Produces **TAC quadruples** row by row during parsing.
   - Uses temporary variables and labels to encode expression evaluation and control flow.

## 3. Design of Intermediate Representation (IR)

### 3.1 Three Address Code

The selected intermediate representation is **Three Address Code (TAC)**. In TAC, each instruction performs a small operation using at most two input operands and one result. This makes the representation simple, readable, and suitable for later optimization or target code generation.

Typical TAC forms used in this project:

- `t1 = b + c`
- `a = t1`
- `ifFalse t1 goto L1`
- `goto L2`
- `label L1`
- `return x`

### 3.2 Quadruple Format

Each TAC instruction is stored and printed in **quadruple form**:

| Field | Meaning |
|---|---|
| `op` | Operation to perform |
| `arg1` | First operand |
| `arg2` | Second operand |
| `result` | Destination or jump target |

Examples:

| op | arg1 | arg2 | result |
|---|---|---|---|
| `+` | `b` | `c` | `t1` |
| `=` | `t1` |  | `a` |
| `ifFalse` | `t2` |  | `L1` |
| `label` |  |  | `L1` |

### 3.3 Temporary Variables

Intermediate values are stored in generated temporaries named:

- `t1`
- `t2`
- `t3`
- ...

The function `new_temp()` in `parser_resolved.y` creates fresh temporaries whenever expression evaluation requires storing an intermediate result.

### 3.4 Labels

Control flow is represented using generated labels such as:

- `L1`
- `L2`
- `L3`
- ...

The function `new_label()` generates unique labels for:

- false branches of `if`
- alternate branches of `if-else`
- loop entry points
- loop exit points
- joins after conditional execution

## 4. Implementation Details

### 4.1 Role of the Lex File

The lexical analyzer is implemented in `minic.l`. It recognizes:

- keywords such as `int`, `float`, `if`, `else`, `while`, `for`, `return`
- identifiers
- integer and floating-point literals
- character and string literals
- arithmetic and relational operators
- delimiters such as parentheses, braces, commas, and semicolons
- comments

It also:

- ignores whitespace
- detects invalid characters
- tracks token positions using `line_number`, `column_number`, and `token_start_column`
- stores the most recent token in `last_token` for diagnostics

### 4.2 Role of the Yacc File

The parser and IR generator are implemented in `parser_resolved.y`. This file:

- defines the MiniC grammar
- performs syntax-directed translation
- emits TAC quadruples through the `emit()` function
- supports expressions, assignments, `if`, `if-else`, `while`, `for`, and `return`
- performs recoverable error reporting via `yyerror()`

### 4.3 Expression Handling

Expressions are parsed using layered grammar rules:

- `assignment_expression`
- `relational_expression`
- `additive_expression`
- `multiplicative_expression`
- `unary_expression`
- `primary_expression`

This layered structure ensures correct precedence and associativity. For example:

- multiplication/division bind more strongly than addition/subtraction
- unary minus is handled before binary arithmetic
- relational expressions produce boolean-like temporary results used in control flow

### 4.4 Assignment Handling

Assignment statements are translated into TAC using the `=` operator. Example:

MiniC:

```c
x = a + b;
```

Generated TAC:

```text
t1 = a + b
x = t1
```

### 4.5 Control Flow Handling

#### IF

For a simple `if`, the parser:

1. evaluates the condition into a temporary if needed
2. generates an `ifFalse` jump to the exit label
3. emits the true branch code
4. emits the exit label

#### IF-ELSE

For `if-else`, the parser:

1. emits `ifFalse cond goto Lfalse`
2. emits the true branch
3. emits `goto Lend`
4. emits `label Lfalse`
5. emits the else branch
6. emits `label Lend`

#### WHILE

For `while`, the parser:

1. emits the loop start label
2. evaluates the loop condition
3. emits `ifFalse cond goto Lexit`
4. emits the loop body
5. emits `goto Lstart`
6. emits `label Lexit`

#### FOR

For `for(init; cond; update)`, the parser:

1. emits code for initialization
2. emits the loop start label
3. evaluates the loop condition
4. emits `ifFalse cond goto Lexit`
5. temporarily captures the update expression
6. emits the loop body
7. flushes the captured update code
8. jumps back to the loop start
9. emits the exit label

This design ensures correct `for` loop ordering.

## 5. Syntax Directed Translation (SDT)

The core of the assignment is implemented through **semantic actions inside grammar productions**. Rather than building a full explicit AST and traversing it later, the parser generates TAC directly during reductions.

Important SDT mechanisms used in the project:

- `emit(op, arg1, arg2, result)` appends a quadruple
- `new_temp()` creates temporaries for intermediate expression values
- `new_label()` creates control-flow labels
- semantic attributes carry the names of identifiers, literals, temporaries, and labels across productions

### Mid-Rule Actions

Mid-rule actions are especially important for correct control-flow ordering. In this project, they are used to:

- create branch labels before the corresponding statement is parsed
- emit `ifFalse` jumps at the correct point
- capture `for` loop update expressions separately

This is particularly important for `if-else`, where the label for the false branch must be known before parsing the then-statement and where a jump to the join point must be emitted before the else-statement begins.

## 6. Error Handling

Error handling is integrated into both the lexer and parser.

### 6.1 Lexical Error Handling

The lexer reports:

- invalid characters
- unclosed block comments

### 6.2 Syntax Error Handling

The parser reports:

- malformed arithmetic expressions
- missing or extra semicolons
- unmatched `else`
- malformed loop conditions
- missing braces or incomplete blocks

### 6.3 Crash Prevention

The implementation is designed to continue parsing after certain errors using recovery rules such as:

- `error SEMICOLON`
- invalid-token handling inside statements

As a result, the compiler can:

- print diagnostics
- preserve partial TAC where possible
- terminate gracefully instead of crashing

Evidence for error handling is available under:

- [Error_diagnostics_results/output](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output)

## 7. Output Format

The generated intermediate code is printed in a structured quadruple table with the following columns:

- `No.`
- `Statement`
- `Op`
- `Arg1`
- `Arg2`
- `Result`

This design improves readability in two ways:

1. The `Statement` column provides a human-readable TAC statement.
2. The remaining columns preserve the exact quadruple representation used internally.

The output is printed top to bottom in the exact execution-oriented order in which the TAC is generated.

## 8. End-to-End Pipeline Explanation

The complete data flow of the compiler is as follows:

1. **Input Program**
   - A MiniC source file is supplied to the parser executable.

2. **Lexical Analysis**
   - The lexer scans the input character stream.
   - It recognizes valid lexemes and returns tokens to the parser.
   - Invalid characters or malformed comments are diagnosed immediately.

3. **Parsing**
   - The Yacc parser consumes the token stream.
   - Grammar productions validate whether the input follows the MiniC syntax.
   - Expression precedence and control-flow structures are resolved by grammar rules.

4. **Syntax Directed Translation**
   - During parsing, semantic actions execute automatically.
   - These actions create temporaries, labels, and quadruples.

5. **TAC Generation**
   - Arithmetic and relational expressions produce temporary results.
   - Assignments emit copy operations.
   - `if`, `if-else`, `while`, and `for` produce branch and label instructions.

6. **Final Output**
   - The compiler prints:
     - the input source program
     - parsing status
     - the complete TAC quadruple table

**Note:** The implementation performs direct SDT-based TAC generation without requiring a separate explicit AST construction phase. The grammar reductions and semantic attributes act as the operational bridge between parsing and IR emission.

## 9. Test Cases and Results

The report evidence below is extracted from:

- [test_cases/all_test_outputs.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/all_test_outputs.txt)

To keep the report submission-ready and evidence-based, the following 10 examples are reproduced from the generated project outputs.

### Test Case 1: Arithmetic Expression With Precedence

**Input Program**

```c
int main() {
    a = (b + c) * d;
}
```

**Generated TAC**

```text
No.   | Statement                        | Op           | Arg1         | Arg2         | Result
-------------------------------------------------------------------------------------------------
0     | t1 = b + c                       | +            | b            | c            | t1
1     | t2 = t1 * d                      | *            | t1           | d            | t2
2     | a = t2                           | =            | t2           |              | a
```

### Test Case 2: Unary Minus and Assignment

**Input Program**

```c
int main() {
    a = -b + 5;
    return a;
}
```

**Generated TAC**

```text
No.   | Statement                        | Op           | Arg1         | Arg2         | Result
-------------------------------------------------------------------------------------------------
0     | t1 = minus b                     | uminus       | b            |              | t1
1     | t2 = t1 + 5                      | +            | t1           | 5            | t2
2     | a = t2                           | =            | t2           |              | a
3     | return a                         | return       | a            |              |
```

### Test Case 3: Declarations and Simple Assignments

**Input Program**

```c
int g = 10;

int main() {
    x = g;
    y = x;
    return y;
}
```

**Generated TAC**

```text
No.   | Statement                        | Op           | Arg1         | Arg2         | Result
-------------------------------------------------------------------------------------------------
0     | g = 10                           | =            | 10           |              | g
1     | x = g                            | =            | g            |              | x
2     | y = x                            | =            | x            |              | y
3     | return y                         | return       | y            |              |
```

### Test Case 4: Relational Expression in Assignment

**Input Program**

```c
int main() {
    x = a < b;
    y = x != 0;
    return y;
}
```

**Generated TAC**

```text
No.   | Statement                        | Op           | Arg1         | Arg2         | Result
-------------------------------------------------------------------------------------------------
0     | t1 = a < b                       | <            | a            | b            | t1
1     | x = t1                           | =            | t1           |              | x
2     | t2 = x != 0                      | !=           | x            | 0            | t2
3     | y = t2                           | =            | t2           |              | y
4     | return y                         | return       | y            |              |
```

### Test Case 5: Simple IF Statement

**Input Program**

```c
int main() {
    if (a < b)
        x = a + 1;

    return x;
}
```

**Generated TAC**

```text
No.   | Statement                        | Op           | Arg1         | Arg2         | Result
-------------------------------------------------------------------------------------------------
0     | t1 = a < b                       | <            | a            | b            | t1
1     | ifFalse t1 goto L1               | ifFalse      | t1           |              | L1
2     | t2 = a + 1                       | +            | a            | 1            | t2
3     | x = t2                           | =            | t2           |              | x
4     | label L1                         | label        |              |              | L1
5     | return x                         | return       | x            |              |
```

### Test Case 6: IF-ELSE Statement

**Input Program**

```c
int main() {
    if (a == b)
        x = a;
    else
        x = b;

    return x;
}
```

**Generated TAC**

```text
No.   | Statement                        | Op           | Arg1         | Arg2         | Result
-------------------------------------------------------------------------------------------------
0     | t1 = a == b                      | ==           | a            | b            | t1
1     | ifFalse t1 goto L1               | ifFalse      | t1           |              | L1
2     | x = a                            | =            | a            |              | x
3     | goto L2                          | goto         |              |              | L2
4     | label L1                         | label        |              |              | L1
5     | x = b                            | =            | b            |              | x
6     | label L2                         | label        |              |              | L2
7     | return x                         | return       | x            |              |
```

### Test Case 7: Nested WHILE Loop

**Input Program**

```c
int main() {
    while (i < 5) {
        while (j < 3) {
            j = j + 1;
        }
        i = i + 1;
    }
}
```

**Generated TAC**

```text
No.   | Statement                        | Op           | Arg1         | Arg2         | Result
-------------------------------------------------------------------------------------------------
0     | label L1                         | label        |              |              | L1
1     | t1 = i < 5                       | <            | i            | 5            | t1
2     | ifFalse t1 goto L2               | ifFalse      | t1           |              | L2
3     | label L3                         | label        |              |              | L3
4     | t2 = j < 3                       | <            | j            | 3            | t2
5     | ifFalse t2 goto L4               | ifFalse      | t2           |              | L4
6     | t3 = j + 1                       | +            | j            | 1            | t3
7     | j = t3                           | =            | t3           |              | j
8     | goto L3                          | goto         |              |              | L3
9     | label L4                         | label        |              |              | L4
10    | t4 = i + 1                       | +            | i            | 1            | t4
11    | i = t4                           | =            | t4           |              | i
12    | goto L1                          | goto         |              |              | L1
13    | label L2                         | label        |              |              | L2
```

### Test Case 8: FOR Loop

**Input Program**

```c
int i = 0;

int main() {
    for (i = 0; i < 3; i = i + 1)
        x = x + i;

    return x;
}
```

**Generated TAC**

```text
No.   | Statement                        | Op           | Arg1         | Arg2         | Result
-------------------------------------------------------------------------------------------------
0     | i = 0                            | =            | 0            |              | i
1     | i = 0                            | =            | 0            |              | i
2     | label L1                         | label        |              |              | L1
3     | t1 = i < 3                       | <            | i            | 3            | t1
4     | ifFalse t1 goto L2               | ifFalse      | t1           |              | L2
5     | t3 = x + i                       | +            | x            | i            | t3
6     | x = t3                           | =            | t3           |              | x
7     | t2 = i + 1                       | +            | i            | 1            | t2
8     | i = t2                           | =            | t2           |              | i
9     | goto L1                          | goto         |              |              | L1
10    | label L2                         | label        |              |              | L2
11    | return x                         | return       | x            |              |
```

### Test Case 9: FOR With Nested IF-ELSE

**Input Program**

```c
int limit = 4;

int main() {
    total = 0;

    for (i = 0; i < limit; i = i + 1)
        if (i != 2)
            total = total + i;
        else
            total = total - 1;

    return total;
}
```

**Generated TAC**

```text
No.   | Statement                        | Op           | Arg1         | Arg2         | Result
-------------------------------------------------------------------------------------------------
0     | limit = 4                        | =            | 4            |              | limit
1     | total = 0                        | =            | 0            |              | total
2     | i = 0                            | =            | 0            |              | i
3     | label L1                         | label        |              |              | L1
4     | t1 = i < limit                   | <            | i            | limit        | t1
5     | ifFalse t1 goto L2               | ifFalse      | t1           |              | L2
6     | t3 = i != 2                      | !=           | i            | 2            | t3
7     | ifFalse t3 goto L5               | ifFalse      | t3           |              | L5
8     | t4 = total + i                   | +            | total        | i            | t4
9     | total = t4                       | =            | t4           |              | total
10    | goto L6                          | goto         |              |              | L6
11    | label L5                         | label        |              |              | L5
12    | t5 = total - 1                   | -            | total        | 1            | t5
13    | total = t5                       | =            | t5           |              | total
14    | label L6                         | label        |              |              | L6
15    | t2 = i + 1                       | +            | i            | 1            | t2
16    | i = t2                           | =            | t2           |              | i
17    | goto L1                          | goto         |              |              | L1
18    | label L2                         | label        |              |              | L2
19    | return total                     | return       | total        |              |
```

### Test Case 10: Nested IF-ELSE

**Input Program**

```c
int main() {
    if (a < b) {
        if (c < d)
            x = c;
        else
            x = d;
    } else {
        x = a;
    }
}
```

**Generated TAC**

```text
No.   | Statement                        | Op           | Arg1         | Arg2         | Result
-------------------------------------------------------------------------------------------------
0     | t1 = a < b                       | <            | a            | b            | t1
1     | ifFalse t1 goto L1               | ifFalse      | t1           |              | L1
2     | t2 = c < d                       | <            | c            | d            | t2
3     | ifFalse t2 goto L2               | ifFalse      | t2           |              | L2
4     | x = c                            | =            | c            |              | x
5     | goto L3                          | goto         |              |              | L3
6     | label L2                         | label        |              |              | L2
7     | x = d                            | =            | d            |              | x
8     | label L3                         | label        |              |              | L3
9     | goto L4                          | goto         |              |              | L4
10    | label L1                         | label        |              |              | L1
11    | x = a                            | =            | a            |              | x
12    | label L4                         | label        |              |              | L4
```

These examples demonstrate that the compiler successfully handles:

- arithmetic expressions
- unary operations
- assignment statements
- relational expressions
- `if`
- `if-else`
- nested `if-else`
- `while`
- nested `while`
- `for`
- combinations of loops and conditionals

## 10. Team Contributions

The work distribution can be presented in the following structured form:

| Team Member | Responsibility |
|---|---|
| Member 1 | Designed and implemented the lexical analyzer in Lex/Flex, including keywords, identifiers, literals, operators, delimiters, comments, and lexical error detection |
| Member 2 | Designed the Yacc/Bison grammar for MiniC, including declarations, expressions, statements, and control-flow constructs |
| Member 3 | Implemented syntax-directed translation rules for TAC generation, including temporaries, labels, `if`, `if-else`, `while`, and `for` support |
| Member 4 | Designed test cases, validated generated quadruples, collected output evidence, and prepared the final report and documentation |

This section can be updated with actual names and roll numbers before submission.

## 11. Challenges Faced

### 11.1 IF Statement Ordering

One of the key challenges was generating TAC for `if-else` in the correct order. If labels or jumps are emitted too late, the output order becomes incorrect. This was addressed using mid-rule actions and explicit label generation.

### 11.2 Label Generation Complexity

Nested control-flow statements require multiple labels for starts, false branches, exits, and join points. Care had to be taken to ensure labels remained unique and correctly matched the intended branch structure.

### 11.3 Handling Nested Control Flow

Programs containing nested `if` inside loops, loops inside `else`, and nested loops required careful semantic action ordering. Incorrect emission order could easily lead to broken control-flow TAC.

### 11.4 FOR Loop Update Placement

The update expression in a `for` loop must execute after the loop body but before the next condition check. This was handled by capturing update quadruples temporarily and flushing them at the correct point.

### 11.5 Error Recovery Without Crashing

Another challenge was ensuring that invalid programs generated diagnostics but did not terminate abruptly. Recovery rules and contextual hints in `yyerror()` helped maintain robustness.

## 12. Steps to Run the Code

### Build From Source

To generate the parser, lexer, and executable from source, run:

```bash
bison -d -o parser_ir_new.tab.c parser_resolved.y
flex -o lex.yy.c minic.l
gcc parser_ir_new.tab.c lex.yy.c -o parser_ir_new
```

This produces the executable `parser_ir_new`.

### Run a Single Test Case

Example:

```bash
./parser_ir_new test_cases/test1.c
```

You can similarly run any other test input:

```bash
./parser_ir_new test_cases/test10.c
./parser_ir_new test_cases/test22.c
./parser_ir_new test_cases/test24.c
```

### Generate Outputs for Normal Test Cases

To run the compiler on the valid TAC-generation examples:

```bash
./parser_ir_new test_cases/test1.c
./parser_ir_new test_cases/test2.c
./parser_ir_new test_cases/test3.c
./parser_ir_new test_cases/test4.c
./parser_ir_new test_cases/test5.c
./parser_ir_new test_cases/test6.c
./parser_ir_new test_cases/test7.c
./parser_ir_new test_cases/test8.c
./parser_ir_new test_cases/test9.c
./parser_ir_new test_cases/test10.c
./parser_ir_new test_cases/test17.c
./parser_ir_new test_cases/test18.c
./parser_ir_new test_cases/test19.c
./parser_ir_new test_cases/test20.c
./parser_ir_new test_cases/test21.c
./parser_ir_new test_cases/test22.c
./parser_ir_new test_cases/test23.c
./parser_ir_new test_cases/test24.c
```

### Save Combined Test Outputs

If you want to store the generated outputs in a single evidence file, use:

```bash
./parser_ir_new test_cases/test1.c > test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test2.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test3.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test4.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test5.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test6.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test7.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test8.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test9.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test10.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test11_invalid_expr.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test12_invalid_token.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test13_missing_semicolon.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test14_unmatched_else.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test15_bad_while_condition.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test16_missing_brace.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test17.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test18.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test19.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test20.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test21.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test22.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test23.c >> test_cases/all_test_outputs.txt 2>&1
./parser_ir_new test_cases/test24.c >> test_cases/all_test_outputs.txt 2>&1
```

### Generate Error Diagnostic Output Files

To save the diagnostics for error-handling evidence:

```bash
./parser_ir_new Error_diagnostics_results/Inputs/bad_expr.c > Error_diagnostics_results/output/bad_expr_error.txt 2>&1
./parser_ir_new Error_diagnostics_results/Inputs/extra_semicolon.c > Error_diagnostics_results/output/extra_semicolon_error.txt 2>&1
./parser_ir_new Error_diagnostics_results/Inputs/unmatched_else.c > Error_diagnostics_results/output/unmatched_else_error.txt 2>&1
./parser_ir_new Error_diagnostics_results/Inputs/unclosed_cmnt.c > Error_diagnostics_results/output/unclosed_cmnt_error.txt 2>&1
./parser_ir_new Error_diagnostics_results/Inputs/bad_while.c > Error_diagnostics_results/output/bad_while_error.txt 2>&1
./parser_ir_new Error_diagnostics_results/Inputs/invalid.c > Error_diagnostics_results/output/invalid_error.txt 2>&1
./parser_ir_new Error_diagnostics_results/Inputs/missing_brace.c > Error_diagnostics_results/output/missing_brace_error.txt 2>&1
./parser_ir_new Error_diagnostics_results/Inputs/missing_error.c > Error_diagnostics_results/output/missing_error.txt 2>&1
```

### Existing Executables in the Repository

The repository also already contains generated executables such as:

- `parser`
- `parser_ir`
- `parser_ir_new`
- `parser_resolved`

So if rebuilding is not required, you can directly run:

```bash
./parser_ir_new test_cases/test1.c
```

### Windows PowerShell Form

If you are using PowerShell on Windows, the equivalent style is:

```powershell
.\parser_ir_new test_cases\test1.c
.\parser_ir_new Error_diagnostics_results\Inputs\bad_expr.c *> Error_diagnostics_results\output\bad_expr_error.txt
```

### Note on the Current Environment

In the current workspace, `gcc` is available, but `bison` and `flex` are not installed in the active PowerShell path. However, the existing executable `parser_ir_new` is already present in the repository and can be used directly for demonstration and evidence generation.

## 13. Conclusion

This assignment successfully demonstrates the design and implementation of a MiniC compiler front end up to the **intermediate code generation** phase. The system performs lexical analysis, parsing, and direct syntax-directed generation of TAC in **quadruple format**. It supports arithmetic expressions, assignments, conditional statements, loops, temporaries, labels, and recoverable error reporting.

From a learning perspective, the assignment provided practical understanding of:

- compiler front-end design
- grammar construction in Yacc/Bison
- tokenization in Lex/Flex
- syntax-directed translation
- representation of control flow using labels and jumps
- the role of TAC as a machine-independent intermediate representation

Overall, the project meets the requirements of the assignment and provides a solid foundation for later phases such as optimization and target code generation.
