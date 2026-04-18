/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    T_INT = 258,
    T_LONG = 259,
    T_SHORT = 260,
    T_FLOAT = 261,
    T_DOUBLE = 262,
    T_CHAR = 263,
    T_VOID = 264,
    T_IF = 265,
    T_ELSE = 266,
    T_WHILE = 267,
    T_DO = 268,
    T_FOR = 269,
    T_SWITCH = 270,
    T_CASE = 271,
    T_DEFAULT = 272,
    T_BREAK = 273,
    T_CONTINUE = 274,
    T_RETURN = 275,
    T_STRUCT = 276,
    T_SIZEOF = 277,
    IDENTIFIER = 278,
    INTEGER_LITERAL = 279,
    FLOAT_LITERAL = 280,
    CHAR_LITERAL = 281,
    STRING_LITERAL = 282,
    PLUS = 283,
    MINUS = 284,
    MUL = 285,
    DIV = 286,
    MOD = 287,
    ASSIGN = 288,
    LT = 289,
    GT = 290,
    LE = 291,
    GE = 292,
    EQ = 293,
    NE = 294,
    AND = 295,
    OR = 296,
    NOT = 297,
    INC_OP = 298,
    DEC_OP = 299,
    SPACESHIP_OP = 300,
    LPAREN = 301,
    RPAREN = 302,
    LBRACE = 303,
    RBRACE = 304,
    LBRACKET = 305,
    RBRACKET = 306,
    SEMICOLON = 307,
    COMMA = 308,
    COLON = 309,
    INVALID_TOKEN = 310
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
