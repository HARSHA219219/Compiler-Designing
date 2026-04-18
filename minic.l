%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parser_resolved.tab.h"

int line_number = 1;
int column_number = 1;
int token_start_column = 1;
char last_token[100];

void mark_token() {
    token_start_column = column_number;
    strcpy(last_token, yytext);
    column_number += yyleng;
}

static char *dup_lexeme(const char *text) {
    char *copy = (char *)malloc(strlen(text) + 1);
    if (!copy) {
        fprintf(stderr, "Out of memory while storing token text.\n");
        exit(1);
    }
    strcpy(copy, text);
    return copy;
}
%}

%x COMMENT

DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT})*
HEX         0[xX][0-9a-fA-F]+
INT         {DIGIT}+
FLOAT       {DIGIT}+\.{DIGIT}+([eE][+-]?{DIGIT}+)?
CHARCONST   \'(\\.|[^\\\'])\'
STRINGCONST \"([^\\\"\n]|\\.)*\"

%%

"//".*                     { column_number += yyleng; }

"/*"                       { BEGIN(COMMENT); column_number += 2; }
<COMMENT>[^*\n]+          { column_number += yyleng; }
<COMMENT>"*"+[^*/\n]*     { column_number += yyleng; }
<COMMENT>"*/"             { BEGIN(INITIAL); column_number += 2; }
<COMMENT>\n               { line_number++; column_number = 1; }

<<EOF>> {
    if (YY_START == COMMENT) {
        fprintf(stderr,
                "\n===== LEXICAL ERROR =====\n");
        fprintf(stderr,
                "Unclosed comment at line %d\n",
                line_number);
        fprintf(stderr,
                "=========================\n");
    }
    return 0;
}

\n          { line_number++; column_number = 1; }
[ \t\r]+    { column_number += yyleng; }


"int"      { mark_token(); return T_INT; }
"long"     { mark_token(); return T_LONG; }
"short"    { mark_token(); return T_SHORT; }
"float"    { mark_token(); return T_FLOAT; }
"double"   { mark_token(); return T_DOUBLE; }
"char"     { mark_token(); return T_CHAR; }
"void"     { mark_token(); return T_VOID; }
"if"       { mark_token(); return T_IF; }
"else"     { mark_token(); return T_ELSE; }
"while"    { mark_token(); return T_WHILE; }
"do"       { mark_token(); return T_DO; }
"for"      { mark_token(); return T_FOR; }
"switch"   { mark_token(); return T_SWITCH; }
"case"     { mark_token(); return T_CASE; }
"default"  { mark_token(); return T_DEFAULT; }
"break"    { mark_token(); return T_BREAK; }
"continue" { mark_token(); return T_CONTINUE; }
"return"   { mark_token(); return T_RETURN; }
"struct"   { mark_token(); return T_STRUCT; }
"sizeof"   { mark_token(); return T_SIZEOF; }


{FLOAT}       { mark_token(); yylval.str = dup_lexeme(yytext); return FLOAT_LITERAL; }
{HEX}         { mark_token(); yylval.str = dup_lexeme(yytext); return INTEGER_LITERAL; }
{INT}         { mark_token(); yylval.str = dup_lexeme(yytext); return INTEGER_LITERAL; }
{CHARCONST}   { mark_token(); yylval.str = dup_lexeme(yytext); return CHAR_LITERAL; }
{STRINGCONST} { mark_token(); yylval.str = dup_lexeme(yytext); return STRING_LITERAL; }


{ID}          { mark_token(); yylval.str = dup_lexeme(yytext); return IDENTIFIER; }


"++"  { mark_token(); return INC_OP; }
"--"  { mark_token(); return DEC_OP; }
"<=>" { mark_token(); return SPACESHIP_OP; }
"<="  { mark_token(); return LE; }
">="  { mark_token(); return GE; }
"=="  { mark_token(); return EQ; }
"!="  { mark_token(); return NE; }
"&&"  { mark_token(); return AND; }
"||"  { mark_token(); return OR; }

"+"   { mark_token(); return PLUS; }
"-"   { mark_token(); return MINUS; }
"*"   { mark_token(); return MUL; }
"/"   { mark_token(); return DIV; }
"%"   { mark_token(); return MOD; }
"="   { mark_token(); return ASSIGN; }
"<"   { mark_token(); return LT; }
">"   { mark_token(); return GT; }
"!"   { mark_token(); return NOT; }


"("   { mark_token(); return LPAREN; }
")"   { mark_token(); return RPAREN; }
"{"   { mark_token(); return LBRACE; }
"}"   { mark_token(); return RBRACE; }
"["   { mark_token(); return LBRACKET; }
"]"   { mark_token(); return RBRACKET; }
";"   { mark_token(); return SEMICOLON; }
","   { mark_token(); return COMMA; }
":"   { mark_token(); return COLON; }


. {
    mark_token();
    return INVALID_TOKEN;
}

%%

int yywrap() {
    return 1;
}
