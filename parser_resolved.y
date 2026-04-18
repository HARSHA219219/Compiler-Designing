%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int line_number;
extern int column_number;
extern int token_start_column;
extern char last_token[];
extern char* yytext;
extern int yylex();

void yyerror(const char *s);

typedef struct {
    char op[16];
    char arg1[64];
    char arg2[64];
    char result[64];
} Quadruple;

Quadruple quadruples[2000];
int quad_count = 0;
int temp_count = 0;
int label_count = 0;
Quadruple captured_quads[500];
int captured_quad_count = 0;
int capture_mode = 0;
int parse_error_flag = 0;

static char *dup_text(const char *text) {
    char *copy = (char *)malloc(strlen(text) + 1);
    if (!copy) {
        fprintf(stderr, "Out of memory while duplicating semantic value.\n");
        exit(1);
    }
    strcpy(copy, text);
    return copy;
}

static char *new_temp() {
    char buffer[32];
    sprintf(buffer, "t%d", ++temp_count);
    return dup_text(buffer);
}

static char *new_label() {
    char buffer[32];
    sprintf(buffer, "L%d", ++label_count);
    return dup_text(buffer);
}

static void emit(const char *op, const char *arg1, const char *arg2, const char *result) {
    Quadruple *target;
    int *count;

    if (capture_mode) {
        if (captured_quad_count >= 500) {
            fprintf(stderr, "Captured quadruple buffer overflow.\n");
            exit(1);
        }
        target = &captured_quads[captured_quad_count];
        count = &captured_quad_count;
    } else {
        if (quad_count >= 2000) {
            fprintf(stderr, "Quadruple buffer overflow.\n");
            exit(1);
        }
        target = &quadruples[quad_count];
        count = &quad_count;
    }

    strncpy(target->op, op ? op : "", sizeof(target->op) - 1);
    strncpy(target->arg1, arg1 ? arg1 : "", sizeof(target->arg1) - 1);
    strncpy(target->arg2, arg2 ? arg2 : "", sizeof(target->arg2) - 1);
    strncpy(target->result, result ? result : "", sizeof(target->result) - 1);

    target->op[sizeof(target->op) - 1] = '\0';
    target->arg1[sizeof(target->arg1) - 1] = '\0';
    target->arg2[sizeof(target->arg2) - 1] = '\0';
    target->result[sizeof(target->result) - 1] = '\0';
    (*count)++;
}

static void start_quad_capture() {
    capture_mode = 1;
    captured_quad_count = 0;
}

static void stop_quad_capture() {
    capture_mode = 0;
}

static void flush_captured_quads() {
    for (int i = 0; i < captured_quad_count; i++) {
        emit(captured_quads[i].op,
             captured_quads[i].arg1,
             captured_quads[i].arg2,
             captured_quads[i].result);
    }
    captured_quad_count = 0;
}

static void print_quadruples() {
    printf("\n=== THREE ADDRESS CODE (QUADRUPLES) ===\n");
    printf("%-5s | %-32s | %-12s | %-12s | %-12s | %-12s\n", "No.", "Statement", "Op", "Arg1", "Arg2", "Result");
    printf("-------------------------------------------------------------------------------------------------\n");

    for (int i = 0; i < quad_count; i++) {
        char statement[256];
        statement[0] = '\0';

        if (strcmp(quadruples[i].op, "uminus") == 0) {
            snprintf(statement, sizeof(statement), "%s = minus %s",
                     quadruples[i].result, quadruples[i].arg1);
        } else if (strcmp(quadruples[i].op, "=") == 0) {
            snprintf(statement, sizeof(statement), "%s = %s",
                     quadruples[i].result, quadruples[i].arg1);
        } else if (strcmp(quadruples[i].op, "label") == 0) {
            snprintf(statement, sizeof(statement), "label %s",
                     quadruples[i].result);
        } else if (strcmp(quadruples[i].op, "goto") == 0) {
            snprintf(statement, sizeof(statement), "goto %s",
                     quadruples[i].result);
        } else if (strcmp(quadruples[i].op, "ifFalse") == 0) {
            snprintf(statement, sizeof(statement), "ifFalse %s goto %s",
                     quadruples[i].arg1, quadruples[i].result);
        } else if (strcmp(quadruples[i].op, "return") == 0) {
            snprintf(statement, sizeof(statement), "return %s",
                     quadruples[i].arg1);
        } else {
            snprintf(statement, sizeof(statement), "%s = %s %s %s",
                     quadruples[i].result,
                     quadruples[i].arg1,
                     quadruples[i].op,
                     quadruples[i].arg2);
        }

        printf("%-5d | %-32s | %-12s | %-12s | %-12s | %-12s\n",
               i,
               statement,
               quadruples[i].op,
               quadruples[i].arg1,
               quadruples[i].arg2,
               quadruples[i].result);
    }

    if (quad_count == 0) {
        printf("(no quadruples generated)\n");
    }
}

static void print_source_program(const char *path) {
    FILE *source = fopen(path, "r");
    char line[512];
    int printed_any = 0;
    int last_had_newline = 1;

    if (!source) {
        fprintf(stderr, "Could not reopen source file for display: %s\n", path);
        return;
    }

    printf("=== INPUT SOURCE PROGRAM ===\n");
    while (fgets(line, sizeof(line), source) != NULL) {
        size_t len = strlen(line);
        fputs(line, stdout);
        printed_any = 1;
        last_had_newline = (len > 0 && line[len - 1] == '\n');
    }
    if (printed_any && !last_had_newline) {
        printf("\n");
    }
    printf("\n");
    fclose(source);
}


/* 
   --------------------------------------------------------------------------
   REVERSE DERIVATION TRACKING
   --------------------------------------------------------------------------
*/
typedef struct {
    int prod_id;
    char prod_text[256];
} DerivationStep;

DerivationStep derivation_stack[2000];
int derivation_ptr = 0;

void add_derivation(int id, const char* text) {
    if (derivation_ptr < 2000) {
        derivation_stack[derivation_ptr].prod_id = id;
        strncpy(derivation_stack[derivation_ptr].prod_text, text, 255);
        derivation_ptr++;
    }
}

void print_reverse_derivation() {
    printf("\n=== REVERSE DERIVATION TREE (Rightmost Derivation in Reverse) ===\n");
    printf("%-5s | %s\n", "Rule", "Production Content");
    printf("------------------------------------------------------------------\n");
    for (int i = derivation_ptr - 1; i >= 0; i--) {
        printf("P%-4d | %s\n", derivation_stack[i].prod_id, derivation_stack[i].prod_text);
    }
}

%}

%code requires {
typedef struct {
    char *start;
    char *middle;
    char *end;
} ControlLabels;
}

%union {
    char *str;
    ControlLabels ctrl;
}


/* Token definitions compatible with updated minic.l */
%token T_INT T_LONG T_SHORT T_FLOAT T_DOUBLE T_CHAR T_VOID
%token T_IF T_ELSE T_WHILE T_DO T_FOR T_SWITCH T_CASE T_DEFAULT
%token T_BREAK T_CONTINUE T_RETURN T_STRUCT T_SIZEOF
%token <str> IDENTIFIER INTEGER_LITERAL FLOAT_LITERAL CHAR_LITERAL STRING_LITERAL
%token PLUS MINUS MUL DIV MOD ASSIGN
%token LT GT LE GE EQ NE AND OR NOT
%token INC_OP DEC_OP SPACESHIP_OP
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET SEMICOLON COMMA COLON
%token INVALID_TOKEN

%nonassoc LOWER_THAN_ELSE
%nonassoc T_ELSE

%type <str> expression assignment_expression relational_expression relop opt_expression
%type <str> additive_expression multiplicative_expression unary_expression primary_expression
%type <str> marker_if marker_else marker_while marker_for capture_begin capture_end if_prefix
%type <ctrl> while_prefix for_prefix

/* 
   --------------------------------------------------------------------------
   GRAMMAR VERSION SELECTION
   --------------------------------------------------------------------------
   VERSION 1: Flat Ambiguous (Default - Shows 80+ Conflicts)
   VERSION 2: Layered Resolved (See commented section at bottom)
*/

%%

program:
    translation_unit { add_derivation(1, "program -> translation_unit"); }
    ;

translation_unit:
    external_declaration { add_derivation(2, "translation_unit -> external_declaration"); }
    | translation_unit external_declaration { add_derivation(3, "translation_unit -> translation_unit external_declaration"); }
    ;

external_declaration:
    declaration { add_derivation(4, "external_declaration -> declaration"); }
    | function_definition { add_derivation(5, "external_declaration -> function_definition"); }
    ;

function_definition:
    type_specifier IDENTIFIER LPAREN RPAREN compound_statement { 
        add_derivation(6, "function_definition -> type IDENTIFIER () compound_statement"); 
    }
    ;

declaration:
    type_specifier init_declarator_list SEMICOLON { add_derivation(7, "declaration -> type init_declarator_list ;"); }
    ;

init_declarator_list:
    init_declarator { add_derivation(8, "init_declarator_list -> init_declarator"); }
    | init_declarator_list COMMA init_declarator { add_derivation(9, "init_declarator_list -> init_declarator_list , init_declarator"); }
    ;

init_declarator:
    IDENTIFIER { add_derivation(10, "init_declarator -> IDENTIFIER"); }
    | IDENTIFIER ASSIGN expression
    {
        emit("=", $3, "", $1);
        add_derivation(11, "init_declarator -> IDENTIFIER = expression");
    }
    ;

type_specifier:
    T_INT { add_derivation(12, "type_specifier -> int"); }
    | T_FLOAT { add_derivation(13, "type_specifier -> float"); }
    | T_VOID { add_derivation(14, "type_specifier -> void"); }
    | T_CHAR { add_derivation(15, "type_specifier -> char"); }
    ;

compound_statement:
    LBRACE block_item_list RBRACE { add_derivation(16, "compound_statement -> { block_item_list }"); }
    | LBRACE RBRACE { add_derivation(17, "compound_statement -> { }"); }
    ;

block_item_list:
    block_item { add_derivation(18, "block_item_list -> block_item"); }
    | block_item_list block_item { add_derivation(19, "block_item_list -> block_item_list block_item"); }
    ;

block_item:
    declaration { add_derivation(20, "block_item -> declaration"); }
    | statement { add_derivation(21, "block_item -> statement"); }
    ;

statement:
    matched_statement
    | unmatched_statement
    ;

expression_statement:
    expression SEMICOLON { add_derivation(25, "expression_statement -> expression ;"); }
    ;

other_statement:
    compound_statement { add_derivation(22, "statement -> compound_statement"); }
    | expression_statement { add_derivation(23, "statement -> expression_statement"); }
    | jump_statement { add_derivation(24, "statement -> jump_statement"); }
    | SEMICOLON
    {
        yyerror("Syntax error: Extra semicolon");
        yyerrok;
    }
    | INVALID_TOKEN
    {
        yyerror("Lexical error: Invalid character encountered");
        yyerrok;
    }
    | error SEMICOLON
    {
        yyerror("Syntax error: Recovering at next semicolon");
        yyerrok;
    }
    ;

matched_statement:
    other_statement
    | iteration_statement { add_derivation(23, "statement -> iteration_statement"); }
    | if_prefix matched_statement T_ELSE
    {
        $<str>$ = new_label();
        emit("goto", "", "", $<str>$);
        emit("label", "", "", $1);
    }
    matched_statement
    {
        emit("label", "", "", $<str>4);
        add_derivation(28, "selection_statement -> if (expr) statement else statement");
    }
    ;

unmatched_statement:
    if_prefix statement
    {
        emit("label", "", "", $1);
        add_derivation(27, "selection_statement -> if (expr) statement");
    }
    | if_prefix matched_statement T_ELSE
    {
        $<str>$ = new_label();
        emit("goto", "", "", $<str>$);
        emit("label", "", "", $1);
    }
    unmatched_statement
    {
        emit("label", "", "", $<str>4);
        add_derivation(28, "selection_statement -> if (expr) statement else statement");
    }
    ;


iteration_statement:
    while_prefix matched_statement
    {
        emit("goto", "", "", $1.start);
        emit("label", "", "", $1.end);
        add_derivation(29, "iteration_statement -> while (expr) statement"); 
    }
    | for_prefix matched_statement
    {
        flush_captured_quads();
        emit("goto", "", "", $1.start);
        emit("label", "", "", $1.end);
        add_derivation(32, "iteration_statement -> for (opt_expr ; opt_expr ; opt_expr) statement");
    }
    ;

if_prefix:
    T_IF LPAREN expression RPAREN marker_if
    {
        emit("ifFalse", $3, "", $5);
        $$ = $5;
    }
    ;

while_prefix:
    T_WHILE marker_while LPAREN
    {
        emit("label", "", "", $2);
    }
    expression RPAREN marker_if
    {
        emit("ifFalse", $5, "", $7);
        $$.start = $2;
        $$.middle = NULL;
        $$.end = $7;
    }
    ;

for_prefix:
    T_FOR LPAREN opt_expression SEMICOLON marker_for
    {
        emit("label", "", "", $5);
    }
    opt_expression SEMICOLON marker_if capture_begin opt_expression capture_end RPAREN
    {
        if ($7 != NULL && strlen($7) > 0) {
            emit("ifFalse", $7, "", $9);
        }
        $$.start = $5;
        $$.middle = NULL;
        $$.end = $9;
    }
    ;

marker_if:
    /* empty */
    {
        $$ = new_label();
    }
    ;

marker_else:
    /* empty */
    {
        $$ = new_label();
    }
    ;

marker_while:
    /* empty */
    {
        $$ = new_label();
    }
    ;

marker_for:
    /* empty */
    {
        $$ = new_label();
    }
    ;

capture_begin:
    marker_for
    {
        start_quad_capture();
        $$ = $1;
    }
    ;

capture_end:
    marker_for
    {
        stop_quad_capture();
        $$ = $1;
    }
    ;

jump_statement:
    T_RETURN expression SEMICOLON
    {
        emit("return", $2, "", "");
        add_derivation(30, "jump_statement -> return expr ;");
    }
    | T_RETURN SEMICOLON
    {
        emit("return", "", "", "");
        add_derivation(31, "jump_statement -> return ;");
    }
    ;

/* 
   --------------------------------------------------------------------------
   VERSION 1: TRULY AMBIGUOUS FLAT GRAMMAR
   --------------------------------------------------------------------------
   This generates massive Shift/Reduce conflicts in parser.output.
*/

/*
expression:
    primary_expression { add_derivation(32, "expression -> primary_expression"); }
    | expression PLUS expression { add_derivation(33, "expression -> expression + expression"); }
    | expression MINUS expression { add_derivation(34, "expression -> expression - expression"); }
    | expression MUL expression { add_derivation(35, "expression -> expression * expression"); }
    | expression DIV expression { add_derivation(36, "expression -> expression / expression"); }
    | IDENTIFIER ASSIGN expression { add_derivation(37, "expression -> IDENTIFIER = expression"); }
    ;
*/

expression:
    assignment_expression
    {
        $$ = $1;
        add_derivation(34, "expression -> assignment_expression");
    }
    ;

assignment_expression:
    relational_expression
    {
        $$ = $1;
        add_derivation(35, "assignment_expression -> relational_expression");
    }
    | IDENTIFIER ASSIGN assignment_expression
    {
        emit("=", $3, "", $1);
        $$ = dup_text($1);
        add_derivation(36, "assignment_expression -> IDENTIFIER = assignment_expression");
    }
    ;

relational_expression:
    additive_expression
    {
        $$ = $1;
        add_derivation(37, "relational_expression -> additive_expression");
    }
    | relational_expression relop additive_expression
    {
        char *temp = new_temp();
        emit($2, $1, $3, temp);
        $$ = temp;
        add_derivation(38, "relational_expression -> relational_expression relop additive_expression");
    }
    ;

relop:
    LT { $$ = dup_text("<"); }
    | GT { $$ = dup_text(">"); }
    | LE { $$ = dup_text("<="); }
    | GE { $$ = dup_text(">="); }
    | EQ { $$ = dup_text("=="); }
    | NE { $$ = dup_text("!="); }
    ;

opt_expression:
    expression
    {
        $$ = $1;
    }
    | /* empty */
    {
        $$ = NULL;
    }
    ;

additive_expression:
    multiplicative_expression
    {
        $$ = $1;
        add_derivation(39, "additive_expression -> multiplicative_expression");
    }
    | additive_expression PLUS multiplicative_expression
    {
        char *temp = new_temp();
        emit("+", $1, $3, temp);
        $$ = temp;
        add_derivation(40, "additive_expression -> additive_expression + multiplicative_expression");
    }
    | additive_expression MINUS multiplicative_expression
    {
        char *temp = new_temp();
        emit("-", $1, $3, temp);
        $$ = temp;
        add_derivation(41, "additive_expression -> additive_expression - multiplicative_expression");
    }
    ;

multiplicative_expression:
    unary_expression
    {
        $$ = $1;
        add_derivation(42, "multiplicative_expression -> unary_expression");
    }
    | multiplicative_expression MUL unary_expression
    {
        char *temp = new_temp();
        emit("*", $1, $3, temp);
        $$ = temp;
        add_derivation(43, "multiplicative_expression -> multiplicative_expression * unary_expression");
    }
    | multiplicative_expression DIV unary_expression
    {
        char *temp = new_temp();
        emit("/", $1, $3, temp);
        $$ = temp;
        add_derivation(44, "multiplicative_expression -> multiplicative_expression / unary_expression");
    }
    ;

unary_expression:
    primary_expression
    {
        $$ = $1;
        add_derivation(45, "unary_expression -> primary_expression");
    }
    | MINUS unary_expression
    {
        char *temp = new_temp();
        emit("uminus", $2, "", temp);
        $$ = temp;
        add_derivation(46, "unary_expression -> - unary_expression");
    }
    ;

primary_expression:
    IDENTIFIER
    {
        $$ = dup_text($1);
        add_derivation(47, "primary_expression -> IDENTIFIER");
    }
    | INTEGER_LITERAL
    {
        $$ = dup_text($1);
        add_derivation(48, "primary_expression -> INTEGER_LITERAL");
    }
    | FLOAT_LITERAL
    {
        $$ = dup_text($1);
        add_derivation(49, "primary_expression -> FLOAT_LITERAL");
    }
    | LPAREN expression RPAREN
    {
        $$ = $2;
        add_derivation(50, "primary_expression -> ( expression )");
    }
    ;

/* 
   --------------------------------------------------------------------------
   VERSION 2: LAYERED RESOLVED GRAMMAR (For Conflict Resolution)
   --------------------------------------------------------------------------
   Copy and use this section to replace the 'expression' block above to resolve
   all arithmetic precedence conflicts.

   expression:
       assignment_expression
       ;

   assignment_expression:
       logical_or_expression
       | IDENTIFIER ASSIGN assignment_expression
       ;

   logical_or_expression:
       additive_expression
       ;

   additive_expression:
       multiplicative_expression
       | additive_expression PLUS multiplicative_expression
       | additive_expression MINUS multiplicative_expression
       ;

   multiplicative_expression:
       primary_expression
       | multiplicative_expression MUL primary_expression
       | multiplicative_expression DIV primary_expression
       ;
*/

%%

/* 
   --------------------------------------------------------------------------
   ERROR DIAGNOSTICS
   --------------------------------------------------------------------------
*/
void yyerror(const char *msg) {
    parse_error_flag = 1;
    fprintf(stderr, "=========== ERROR DIAGNOSTICS ===========\n");
    fprintf(stderr, "Message : %s\n", msg);
    fprintf(stderr, "Line    : %d\n", line_number);
    fprintf(stderr, "Column  : %d\n", token_start_column);
    fprintf(stderr, "Token   : '%s'\n", last_token);

    if (strcmp(last_token, "*") == 0 || strcmp(last_token, "/") == 0)
        fprintf(stderr, "Hint    : Invalid arithmetic expression near '%s'.\n", last_token);
    else if (strcmp(last_token, ";") == 0)
        fprintf(stderr, "Hint    : Unexpected semicolon or missing expression before ';'.\n");
    else if (strcmp(last_token, "int") == 0 || strcmp(last_token, "float") == 0 ||
             strcmp(last_token, "char") == 0 || strcmp(last_token, "void") == 0)
        fprintf(stderr, "Hint    : Check whether a declaration appears after a malformed statement.\n");
    else if (strcmp(last_token, "else") == 0)
        fprintf(stderr, "Hint    : 'else' may not match any previous if.\n");
    else if (strcmp(last_token, "@") == 0 || strcmp(last_token, "INVALID_TOKEN") == 0)
        fprintf(stderr, "Hint    : Unsupported or invalid character in source program.\n");
    else
        fprintf(stderr, "Hint    : Review syntax near current token.\n");

    fprintf(stderr, "=========================================\n");
}

int main(int argc, char **argv) {
    const char *input_path = NULL;

    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror("Error opening file");
            return 1;
        }
        extern FILE *yyin;
        yyin = file;
        input_path = argv[1];
    }

    printf("Starting MiniC LALR(1) Parsing...\n\n");
    if (input_path != NULL) {
        print_source_program(input_path);
    }

    yyparse();

    if (parse_error_flag == 0)
        printf("\nParsing completed successfully.\n");
    else
        printf("\nParsing completed with recoverable errors.\n");

    print_quadruples();
    
    return 0;
}
