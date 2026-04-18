# Error Diagnostics Results

## Purpose

This document presents the **error-handling evidence** for our MiniC compiler. The goal of this section is to show that the compiler does not crash on invalid input and instead produces meaningful diagnostics with line number, column number, offending token, and a recovery-oriented hint.

The evidence in this folder is based on two kinds of files:

- bad input programs in [Inputs](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs)
- captured compiler outputs in [output](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output)

This directly supports the assignment requirement:

- detect invalid expressions or unsupported constructs
- display meaningful error messages
- ensure the program does not crash on incorrect input

## What We Checked

We intentionally tested multiple classes of invalid MiniC programs:

- malformed arithmetic expressions
- extra semicolons
- missing expressions
- malformed `while` conditions
- unmatched `else`
- unclosed comments
- combined multi-error input
- incomplete blocks / brace-related failure cases

The main observation is that the compiler reports the problem, points to the token that caused it, and in most cases still completes parsing with **recoverable errors**.

## Diagnostic Format

The parser prints diagnostics in the following style:

```text
=========== ERROR DIAGNOSTICS ===========
Message : ...
Line    : ...
Column  : ...
Token   : '...'
Hint    : ...
=========================================
```

This is strong evidence that the implementation is not silently failing. It is identifying:

- where the problem occurred
- which token triggered it
- what kind of issue is likely present

## Evidence Summary Table

| Case | Input File | Output Evidence | Main Issue |
|---|---|---|---|
| Bad expression | [bad_expr.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/bad_expr.c) | [bad_expr_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/bad_expr_error.txt) | Invalid arithmetic expression near `*` |
| Extra semicolon | [extra_semicolon.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/extra_semicolon.c) | [extra_semicolon_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/extra_semicolon_error.txt) | Redundant semicolon after declaration |
| Missing expression | [missing_error.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/missing_error.c) | [missing_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/missing_error.txt) | Assignment with missing right-hand side |
| Bad while condition | [bad_while.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/bad_while.c) | [bad_while_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/bad_while_error.txt) | Incomplete relational condition in `while` |
| Unmatched else | [unmatched_else.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/unmatched_else.c) | [unmatched_else_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/unmatched_else_error.txt) | `else` without matching `if` |
| Unclosed comment | [unclosed_cmnt.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/unclosed_cmnt.c) | [unclosed_cmnt_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/unclosed_cmnt_error.txt) | Lexical error due to unterminated block comment |
| Multi-error input | [invalid.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/invalid.c) | [invalid_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/invalid_error.txt) | Multiple syntax errors in one program |
| Missing brace case | [missing_brace.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/missing_brace.c) | [missing_brace_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/missing_brace_error.txt) | Incomplete block / missing closing brace |

## Case-by-Case Evidence

### 1. Bad Arithmetic Expression

**Input file:** [bad_expr.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/bad_expr.c)

```c
int main() {
    int x;
    x = a + * 2;
    return 0;
}
```

**Why this is invalid**

The expression `a + * 2` contains two operators in sequence. After `+`, the parser expects a valid operand or subexpression, but it encounters `*`.

**Observed evidence**

From [bad_expr_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/bad_expr_error.txt):

```text
Message : syntax error
Line    : 3
Column  : 13
Token   : '*'
Hint    : Invalid arithmetic expression near '*'.
```

The parser then performs recovery and reports:

```text
Message : Syntax error: Recovering at next semicolon
Line    : 3
Column  : 16
Token   : ';'
Hint    : Unexpected semicolon or missing expression before ';'.
```

**Result**

- the invalid expression is detected
- the exact token `*` is identified
- the compiler does not crash
- partial TAC is still printed after recovery

### 2. Extra Semicolon Case

**Input file:** [extra_semicolon.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/extra_semicolon.c)

```c
int main() {
    int x = 5;;
    return x;
}
```

**Why this is invalid**

This case contains an unnecessary extra semicolon after the declaration. This is exactly the kind of punctuation-related syntax issue that frequently appears in student compilers.

**Observed evidence**

From [extra_semicolon_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/extra_semicolon_error.txt):

```text
Message : Syntax error: Extra semicolon
Line    : 2
Column  : 15
Token   : ';'
Hint    : Unexpected semicolon or missing expression before ';'.
```

**Why this is strong evidence**

This proves the compiler can specifically recognize a semicolon-related conflict instead of only giving a vague generic parse failure. The location and token are both correct.

**Result**

- extra semicolon is detected
- diagnostic is precise
- valid TAC from earlier tokens is preserved

### 3. Missing Expression After Assignment

**Input file:** [missing_error.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/missing_error.c)

```c
int main() {
    int x;
    x = ;
    return 0;
}
```

**Why this is invalid**

The assignment operator `=` must be followed by an expression. Instead, the statement ends immediately with `;`.

**Observed evidence**

From [missing_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/missing_error.txt):

```text
Message : syntax error
Line    : 3
Column  : 9
Token   : ';'
Hint    : Unexpected semicolon or missing expression before ';'.
```

**What this proves**

This is important evidence that semicolon-triggered syntax errors are not being ignored. The compiler correctly interprets `;` here as evidence that the right-hand side expression is missing.

### 4. Malformed While Condition

**Input file:** [bad_while.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/bad_while.c)

```c
int main() {
    while (x < ) {
        x = x + 1;
    }
}
```

**Why this is invalid**

The relational expression inside the `while` condition is incomplete. After `<`, another operand is required, but the parser reaches `)`.

**Observed evidence**

From [bad_while_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/bad_while_error.txt):

```text
Message : syntax error
Line    : 2
Column  : 16
Token   : ')'
Hint    : Review syntax near current token.
```

Additional recovery messages are also produced later, including a semicolon-based recovery and a closing-brace-related syntax message.

**Result**

- malformed loop condition is detected
- parser enters recovery mode
- the compiler still terminates safely

### 5. Unmatched Else

**Input file:** [unmatched_else.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/unmatched_else.c)

```c
int main() {
    else x = 5;
}
```

**Why this is invalid**

An `else` must be paired with a preceding `if`. Here it appears by itself.

**Observed evidence**

From [unmatched_else_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/unmatched_else_error.txt):

```text
Message : syntax error
Line    : 2
Column  : 5
Token   : 'else'
Hint    : 'else' may not match any previous if.
```

**Result**

- unmatched `else` is explicitly recognized
- the hint is context-aware
- the compiler reports recoverable errors rather than crashing

### 6. Unclosed Multi-Line Comment

**Input file:** [unclosed_cmnt.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/unclosed_cmnt.c)

```c
int main() {
    int x = 5;
    /* this comment never closes
    return x;
}
```

**Why this is invalid**

The block comment begins with `/*` but never ends with `*/`. This is a lexical error, not just a parse error.

**Observed evidence**

From [unclosed_cmnt_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/unclosed_cmnt_error.txt):

```text
===== LEXICAL ERROR =====
Unclosed comment at line 6
=========================
```

The parser then also reports a follow-up syntax issue because the input stream ends in a broken state.

**What this proves**

This is strong evidence that the lexer itself performs validation and does not leave comment handling unchecked.

### 7. Combined Multi-Error Program

**Input file:** [invalid.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/invalid.c)

This file intentionally contains multiple different mistakes:

- bad arithmetic expression
- missing semicolon before `else`
- unmatched `else` structure
- malformed subtraction in `while`
- incomplete `return`

**Observed evidence**

From [invalid_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/invalid_error.txt), the compiler reports multiple diagnostics such as:

```text
Token   : '*'
Hint    : Invalid arithmetic expression near '*'.
```

```text
Token   : 'else'
Hint    : 'else' may not match any previous if.
```

```text
Token   : ';'
Hint    : Unexpected semicolon or missing expression before ';'.
```

**Why this matters**

This is one of the strongest pieces of evidence in the folder because it shows that the compiler can:

- detect more than one error in a single run
- recover and continue
- still generate whatever partial TAC is possible

That is much stronger than stopping at the first failure.

### 8. Missing Brace / Incomplete Block

**Input file:** [missing_brace.c](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/Inputs/missing_brace.c)

**Output evidence:** [missing_brace_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/missing_brace_error.txt)

This case checks whether the compiler handles incomplete block structure. It is useful because block mismatches are common in `if`, `while`, and compound statements.

This evidence supports the claim that the compiler does not assume well-formed braces and can still report a recoverable failure.

## Why the Semicolon Cases Matter

Several of our error files show that `;` is a major source of syntax problems:

- extra semicolon
- missing expression before semicolon
- recovery at the next semicolon

This is important in a Yacc-based compiler because semicolons are often the parser's synchronization points during recovery. In our implementation, the presence of rules such as error recovery around statement boundaries allows the parser to:

- stop at the faulty statement
- print a meaningful hint
- resume parsing from the next safe point

This is why many outputs contain messages like:

```text
Syntax error: Recovering at next semicolon
```

So yes, strong evidence from these files shows that several conflicts or malformed constructs are being successfully diagnosed **because the parser identifies semicolon boundaries and uses them for recovery**.

## Overall Findings

From the evidence in this folder, we can conclude that the compiler:

- detects syntax and lexical errors across different categories
- prints location-aware diagnostics
- identifies problematic tokens such as `*`, `;`, `)`, and `else`
- uses semicolon-based recovery effectively
- does not crash on malformed source programs
- can still print partial TAC after recoverable errors

## Files to Cite as Strong Evidence

If only a few files are to be shown during evaluation, the strongest evidence files are:

1. [extra_semicolon_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/extra_semicolon_error.txt)
   This clearly proves semicolon-specific detection.

2. [missing_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/missing_error.txt)
   This proves missing-expression detection triggered at `;`.

3. [bad_expr_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/bad_expr_error.txt)
   This shows operator misuse plus recovery.

4. [unmatched_else_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/unmatched_else_error.txt)
   This shows grammar-level control-flow mismatch detection.

5. [unclosed_cmnt_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/unclosed_cmnt_error.txt)
   This shows lexer-level error handling.

6. [invalid_error.txt](/c:/Users/Hp/OneDrive/Documents/assignment_4_Group_19/assignment_4_Group_19/Error_diagnostics_results/output/invalid_error.txt)
   This is the strongest overall file because it demonstrates multiple diagnostics in one program with continued recovery.

## Conclusion

The files in `Error_diagnostics_results` provide clear evidence that the MiniC compiler has meaningful and practical error handling. The implementation does not simply reject invalid programs silently. Instead, it:

- reports what went wrong
- shows where it went wrong
- identifies the token causing the issue
- uses semicolon-based recovery where appropriate
- continues execution safely and prints results without crashing

This satisfies the assignment requirement for robust diagnostics during intermediate code generation.
