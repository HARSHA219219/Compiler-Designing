# Test Cases and TAC Evidence

## Purpose

This document summarizes the **test case evidence** for the MiniC compiler. It shows that the compiler can:

- parse valid MiniC programs
- generate Three Address Code in quadruple format
- handle arithmetic expressions and assignments
- support `if`, `if-else`, `while`, and `for`
- handle nested control flow
- continue safely on invalid inputs with recoverable errors

The main evidence source for this folder is:

- [all_test_outputs.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/all_test_outputs.txt)

The individual input programs are stored in:

- [test_cases](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases)

## What These Test Cases Cover

The test suite checks both normal and abnormal programs.

### Valid TAC generation cases

- arithmetic precedence
- unary minus
- declarations with initialization
- relational expressions
- assignment statements
- simple `if`
- `if-else`
- nested `if-else`
- `while`
- nested `while`
- `for`
- nested control flow
- larger combined programs

### Recoverable error cases inside `test_cases`

- invalid expression
- invalid token
- missing semicolon
- unmatched `else`
- bad `while` condition
- missing brace

## Evidence Summary

| Test File | Main Feature Verified | Parsing Result |
|---|---|---|
| [test1.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test1.c) | Arithmetic precedence | Successful |
| [test2.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test2.c) | Unary minus | Successful |
| [test3.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test3.c) | Simple assignments and globals | Successful |
| [test4.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test4.c) | Declaration initialization | Successful |
| [test5.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test5.c) | Relational expressions | Successful |
| [test6.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test6.c) | Simple `if` | Successful |
| [test7.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test7.c) | `if-else` | Successful |
| [test8.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test8.c) | Nested `while` | Successful |
| [test9.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test9.c) | `for` loop | Successful |
| [test10.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test10.c) | `for` with nested `if-else` | Successful |
| [test17.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test17.c) | `for` with branch inside body | Successful |
| [test18.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test18.c) | `while` with inner `if` | Successful |
| [test19.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test19.c) | Compact `for` loop | Successful |
| [test20.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test20.c) | Alternate `if-else` form | Successful |
| [test21.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test21.c) | Relational condition with arithmetic on both sides | Successful |
| [test22.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test22.c) | Nested `if-else` | Successful |
| [test23.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test23.c) | Multiple `while` loops | Successful |
| [test24.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test24.c) | Large mixed control-flow program | Successful |
| [test11_invalid_expr.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test11_invalid_expr.c) | Invalid expression handling | Recoverable errors |
| [test12_invalid_token.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test12_invalid_token.c) | Invalid token handling | Recoverable errors |
| [test13_missing_semicolon.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test13_missing_semicolon.c) | Missing semicolon handling | Recoverable errors |
| [test14_unmatched_else.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test14_unmatched_else.c) | Unmatched `else` handling | Recoverable errors |
| [test15_bad_while_condition.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test15_bad_while_condition.c) | Invalid `while` condition | Recoverable errors |
| [test16_missing_brace.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test16_missing_brace.c) | Missing brace handling | Recoverable errors |

## Strong Evidence Cases

The following cases are especially useful during demonstration because together they cover the full assignment scope.

### 1. Arithmetic Precedence

**Input:** [test1.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test1.c)

```c
int main() {
    a = (b + c) * d;
}
```

**Observed TAC evidence**

```text
0     | t1 = b + c                       | +            | b            | c            | t1
1     | t2 = t1 * d                      | *            | t1           | d            | t2
2     | a = t2                           | =            | t2           |              | a
```

**What this proves**

- parentheses are respected
- temporaries are generated correctly
- expression evaluation order is correct

### 2. Unary Minus

**Input:** [test2.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test2.c)

```c
int main() {
    a = -b + 5;
    return a;
}
```

**Observed TAC evidence**

```text
0     | t1 = minus b                     | uminus       | b            |              | t1
1     | t2 = t1 + 5                      | +            | t1           | 5            | t2
2     | a = t2                           | =            | t2           |              | a
3     | return a                         | return       | a            |              |
```

**What this proves**

- unary minus is translated using a dedicated TAC operation
- intermediate results are preserved in temporaries

### 3. Simple IF

**Input:** [test6.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test6.c)

```c
int main() {
    if (a < b)
        x = a + 1;

    return x;
}
```

**Observed TAC evidence**

```text
0     | t1 = a < b                       | <            | a            | b            | t1
1     | ifFalse t1 goto L1               | ifFalse      | t1           |              | L1
2     | t2 = a + 1                       | +            | a            | 1            | t2
3     | x = t2                           | =            | t2           |              | x
4     | label L1                         | label        |              |              | L1
5     | return x                         | return       | x            |              |
```

**What this proves**

- condition evaluation generates a temporary
- branch control is expressed using `ifFalse` and labels

### 4. IF-ELSE

**Input:** [test7.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test7.c)

```c
int main() {
    if (a == b)
        x = a;
    else
        x = b;

    return x;
}
```

**Observed TAC evidence**

```text
0     | t1 = a == b                      | ==           | a            | b            | t1
1     | ifFalse t1 goto L1               | ifFalse      | t1           |              | L1
2     | x = a                            | =            | a            |              | x
3     | goto L2                          | goto         |              |              | L2
4     | label L1                         | label        |              |              | L1
5     | x = b                            | =            | b            |              | x
6     | label L2                         | label        |              |              | L2
7     | return x                         | return       | x            |              |
```

**What this proves**

- both branches are translated correctly
- jump-to-join structure is generated correctly

### 5. Nested WHILE

**Input:** [test8.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test8.c)

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

**Observed TAC evidence**

```text
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

**What this proves**

- nested loop labels remain distinct
- inner and outer loop exits are handled properly

### 6. FOR Loop

**Input:** [test9.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test9.c)

```c
int i = 0;

int main() {
    for (i = 0; i < 3; i = i + 1)
        x = x + i;

    return x;
}
```

**Observed TAC evidence**

```text
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

**What this proves**

- initialization, condition, body, and update are emitted in correct order
- `for` loop translation is working as expected

### 7. FOR With Nested IF-ELSE

**Input:** [test10.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test10.c)

**Observed result**

This case is one of the strongest validation programs because it combines:

- declaration initialization
- `for` loop control
- relational comparison
- nested `if-else`
- arithmetic updates
- final `return`

The TAC output in `all_test_outputs.txt` shows correct label flow for the loop and both branches of the nested condition.

### 8. Nested IF-ELSE

**Input:** [test22.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test22.c)

**Observed result**

The generated TAC shows:

- outer false branch label
- inner false branch label
- join label for inner branch
- join label for outer branch

This is strong evidence that nested decision structures are translated correctly.

### 9. Multiple WHILE Loops

**Input:** [test23.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test23.c)

**Observed result**

This case proves that label numbering continues correctly across multiple loops in the same program and that the compiler does not confuse the control flow of separate iterations.

### 10. Large Mixed Program

**Input:** [test24.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test24.c)

**Observed result**

This is the most comprehensive success case in the folder. It includes:

- multiple `for` loops
- `while` loops
- nested `if`
- nested `while`
- mixed arithmetic and relational operations

The generated TAC spans many labels and temporaries, showing that the compiler scales beyond only toy one-statement programs.

## Recoverable Error Test Cases in This Folder

The `test_cases` folder also includes invalid examples that confirm graceful recovery.

| Test File | Observed Result |
|---|---|
| [test11_invalid_expr.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test11_invalid_expr.c) | Parsing completed with recoverable errors; partial TAC still printed |
| [test12_invalid_token.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test12_invalid_token.c) | Invalid token handled; assignment before the fault may still appear in TAC |
| [test13_missing_semicolon.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test13_missing_semicolon.c) | Missing semicolon causes recoverable parse failure |
| [test14_unmatched_else.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test14_unmatched_else.c) | Unmatched `else` handled as recoverable error |
| [test15_bad_while_condition.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test15_bad_while_condition.c) | Broken loop condition does not crash the compiler |
| [test16_missing_brace.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test16_missing_brace.c) | Missing brace still produces controlled output and partial TAC |

These cases complement the dedicated diagnostic folder and show that recovery behavior is visible in the normal test suite as well.

## Strongest Files to Show During Evaluation

If you want the shortest possible demonstration set, the strongest files are:

1. [test1.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test1.c)
   Shows arithmetic TAC generation clearly.

2. [test7.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test7.c)
   Shows `if-else` label and jump generation.

3. [test8.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test8.c)
   Shows nested `while`.

4. [test9.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test9.c)
   Shows `for` loop translation.

5. [test10.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test10.c)
   Shows combined loop and branch handling.

6. [test22.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test22.c)
   Shows nested `if-else`.

7. [test24.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/test_cases/test24.c)
   Shows the largest mixed control-flow example.

## Conclusion

The files in `test_cases` provide clear evidence that the MiniC compiler generates correct TAC in quadruple form for a wide variety of programs. The outputs show correct use of:

- temporaries such as `t1`, `t2`, `t3`
- labels such as `L1`, `L2`, `L3`
- assignment operations
- arithmetic and relational operations
- `ifFalse` jumps
- unconditional `goto`
- `return`

Taken together, these cases demonstrate that the compiler satisfies the assignment requirement for intermediate code generation and extended control-flow support.
