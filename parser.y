%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int line_number;
extern int column_number;
extern char* yytext;
extern int yylex();

void yyerror(const char *s);

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

/* Token definitions compatible with updated minic.l */
%token T_INT T_LONG T_SHORT T_FLOAT T_DOUBLE T_CHAR T_VOID
%token T_IF T_ELSE T_WHILE T_DO T_FOR T_SWITCH T_CASE T_DEFAULT
%token T_BREAK T_CONTINUE T_RETURN T_STRUCT T_SIZEOF
%token IDENTIFIER INTEGER_LITERAL FLOAT_LITERAL CHAR_LITERAL STRING_LITERAL
%token PLUS MINUS MUL DIV MOD ASSIGN
%token LT GT LE GE EQ NE AND OR NOT
%token INC_OP DEC_OP SPACESHIP_OP
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET SEMICOLON COMMA COLON
%token INVALID_TOKEN

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
    | IDENTIFIER ASSIGN expression { add_derivation(11, "init_declarator -> IDENTIFIER = expression"); }
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
    compound_statement { add_derivation(22, "statement -> compound_statement"); }
    | expression_statement { add_derivation(23, "statement -> expression_statement"); }
    | selection_statement { add_derivation(22, "statement -> selection_statement"); }
    | iteration_statement { add_derivation(23, "statement -> iteration_statement"); }
    | jump_statement { add_derivation(24, "statement -> jump_statement"); }
    | SEMICOLON {
        yyerror("Syntax error: Extra semicolon");
        yyerrok;
    }
    | INVALID_TOKEN { 
        yyerror("Lexical error: Invalid character encountered"); 
        yyerrok; 
    }
    | error SEMICOLON { 
        yyerror("Syntax error: Recovering at next semicolon"); 
        yyerrok; 
    }
    ;

expression_statement:
    expression SEMICOLON { add_derivation(25, "expression_statement -> expression ;"); }
    ;

/* Selection Statement (Dangling Else Conflict Point) */
selection_statement:
    T_IF LPAREN expression RPAREN statement { 
        add_derivation(27, "selection_statement -> if (expr) statement"); 
    }
    | T_IF LPAREN expression RPAREN statement T_ELSE statement { 
        add_derivation(28, "selection_statement -> if (expr) statement else statement"); 
    }
    ;

iteration_statement:
    T_WHILE LPAREN expression RPAREN statement { 
        add_derivation(29, "iteration_statement -> while (expr) statement"); 
    }
    ;

jump_statement:
    T_RETURN expression SEMICOLON { add_derivation(30, "jump_statement -> return expr ;"); }
    | T_RETURN SEMICOLON { add_derivation(31, "jump_statement -> return ;"); }
    ;

/* 
   --------------------------------------------------------------------------
   VERSION 1: TRULY AMBIGUOUS FLAT GRAMMAR
   --------------------------------------------------------------------------
   This generates massive Shift/Reduce conflicts in parser.output.
*/
expression:
    primary_expression { add_derivation(32, "expression -> primary_expression"); }
    | expression PLUS expression { add_derivation(33, "expression -> expression + expression"); }
    | expression MINUS expression { add_derivation(34, "expression -> expression - expression"); }
    | expression MUL expression { add_derivation(35, "expression -> expression * expression"); }
    | expression DIV expression { add_derivation(36, "expression -> expression / expression"); }
    | IDENTIFIER ASSIGN expression { add_derivation(37, "expression -> IDENTIFIER = expression"); }
    ;

primary_expression:
    IDENTIFIER { add_derivation(38, "primary_expression -> IDENTIFIER"); }
    | INTEGER_LITERAL { add_derivation(39, "primary_expression -> INTEGER_LITERAL"); }
    | FLOAT_LITERAL { add_derivation(40, "primary_expression -> FLOAT_LITERAL"); }
    | LPAREN expression RPAREN { add_derivation(41, "primary_expression -> ( expression )"); }
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
void yyerror(const char *s) {
    fprintf(stderr, "\n--- SYNTAX ERROR DETECTED ---\n");
    fprintf(stderr, "Message: %s\n", s);
    fprintf(stderr, "Location: Line %d, Column %d\n", line_number, column_number);
    fprintf(stderr, "Offending Token: '%s'\n", yytext);
    
    // Context-specific hints
    if (strcmp(yytext, ";") == 0) {
        fprintf(stderr, "Hint: Possible extra semicolon or empty statement.\n");
    } else if (strcmp(yytext, "}") == 0) {
        fprintf(stderr, "Hint: Check for unmatched brace or missing semicolon in the block.\n");
    } else if (strcmp(yytext, ")") == 0) {
        fprintf(stderr, "Hint: Check for missing expression inside parentheses.\n");
    } else {
        fprintf(stderr, "Hint: Ensure all expressions are terminated by ';' and blocks are correctly nested.\n");
    }
    fprintf(stderr, "-----------------------------\n");
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror("Error opening file");
            return 1;
        }
        extern FILE *yyin;
        yyin = file;
    }

    printf("Starting MiniC LALR(1) Parsing...\n\n");
    
    if (yyparse() == 0) {
        printf("\nSUCCESS: Parsing completed successfully.\n");
        print_reverse_derivation();
    } else {
        printf("\nFAILURE: Parsing failed due to syntax errors.\n");
    }
    
    return 0;
}
