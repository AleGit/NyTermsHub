/*  Created by Alexander Maringele.
    Copyright (c) 2015 Alexander Maringele. All rights reserved.
*/

%{
    
    //  Created by Alexander Maringele.
    //  Copyright (c) 2015 Alexander Maringele. All rights reserved.
    //
    
#import "MereParser.tab.h"

#define TOKEN(k)    { return k; }
#define TSTRING(k)  { mere_lval.cstring = mere_text; return k; }
#define TNUMBER     { mere_lval.number = atol(mere_text); return NUMBER; }
#define TINTEGER 	TSTRING(INTEGER)
#define	TRATIONAL	TSTRING(RATIONAL)
#define TREAL		TSTRING(REAL)

%}

%option yylineno
%option noyywrap
/* to avoid warning: ‘yyunput’ defined but not used */
%option nounput
/* to avoid warning: ‘input’ defined but not used */
%option noinput
/* for the use of multiple lexers (and parsers) */
%option prefix="mere_"
/* similar to -P mere_ (lex) */

/*
 %----Rules from her on down are for defining tokens (terminal symbols) of the
 %----grammar, assuming they will be recognized by a lexical scanner.
 %----A ::- rule defines a token, a ::: rule defines a macro that is not a
 %----token. Usual regexp notation is used. ...
 */

delim		[ \t\n\r]
whitespace	{delim}*

comment				{comment_line}|{comment_block}
comment_line		[%]{printable_char}*
comment_block		[/][*]{not_star_slash}[*]+[/]
not_star_slash		([^*]*[*][*]*[^/*])*[^*]*

single_quoted		[']{sq_char}+[']
distinct_object		["]{do_char}*["]
dollar_word			[$]{lower_word}
dollar_dollar_word 	[$][$]{lower_word}
upper_word			{upper_alpha}{alpha_numeric}*
lower_word			{lower_alpha}{alpha_numeric}*


/*---- Tokens used in syntax, and cannot be character classes */
vline		[|]
star		[*]
plus		[+]
arrow		[>]
less_sign	[<]

/*---- Numbers. Symbols are made part of the same token here. */
real				{signed_real}|{unsigned_real}
signed_real			{sign}{unsigned_real}
unsigned_real		{decimal_fraction}|{decimal_exponent}
rational			{signed_rational}|{unsigned_rational}
signed_rational		{sign}{unsigned_rational}
unsigned_rational	{decimal}{slash}{positive_decimal}
integer				{signed_integer}|{unsigned_integer}
signed_integer		{sign}{unsigned_integer}
unsigned_integer	{decimal}
decimal				{zero_numeric}|{positive_decimal}
positive_decimal	{non_zero_numeric}{numeric}*
decimal_exponent	({decimal}|{decimal_fraction}){exponent}{integer}
decimal_fraction	{decimal}{dot_decimal}
dot_decimal			{dot}{numeric}+

/*---- Character classes */
percentage_sign		[%]
double_quote		["]
do_char				[\40-\41\43-\133\135-\176]|[\\]["\\]
single_quote		[']
/*---- Space and visible characters upto ~, except ' and \ */
sq_char				[\40-\46\50-\133\135-\176]|[\\]['\\]
sign				[+-]
dot					[.]
exponent			[Ee]
slash				[/]
zero_numeric		[0]
non_zero_numeric	[1-9]
numeric				[0-9]
lower_alpha			[a-z]
upper_alpha			[A-Z]
alpha_numeric		{lower_alpha}|{upper_alpha}|{numeric}|[_]
dollar				[$]
printable_char		.
viewable_char		[.\n]

%%

{comment}				;

"$fof"						TOKEN(DOLLAR_FOF)
"$fot"						TOKEN(DOLLAR_FOT)
"$cnf"						TOKEN(DOLLAR_CNF)

"fof"						TOKEN(FOF)
"cnf"						TOKEN(CNF)
"include"					TOKEN(INCLUDE)

"description"				TOKEN(DESCRIPTION)
"iquote"					TOKEN(IQUOTE)
"!="						TOKEN(INFIX_INEQUALITY)

{single_quoted}				TSTRING(SINGLE_QUOTED)
{distinct_object}			TSTRING(DISTINCT_OBJECT)
{dollar_word}				TSTRING(DOLLAR_WORD)
{dollar_dollar_word}		TSTRING(DOLLAR_DOLLAR_WORD)
{lower_word}				TSTRING(LOWER_WORD)
{upper_word}				TSTRING(UPPER_WORD)

{integer}					TINTEGER
{rational}					TRATIONAL
{real}						TREAL

"<=>"						TOKEN(IFF)
"=>"						TOKEN(IMPLY)
"<="						TOKEN(YLPMI)
"<~>"						TOKEN(NIFF)
"~|"						TOKEN(NOR)
"~&"						TOKEN(NAND)

"-->"						TOKEN(GENTZEN_ARROW)

"|"		|					/* vline */
"*"		|					/* star */
"+"		|					/* plus */
">"		|					/* arrow */
"<"		|					/* less_sign */
"\""	|					/* double_quote */
"'"		|					/* single_quote */
"."		|					/* dot */
"/"		|					/* slash */
"$"		|					/* dollar */
"(" 	|
","		| 
")" 	|
"~"		|
"!"		|                   /* universal quantifier */
"?"		|                   /* existential quantifier */
"["		|
"]"		|
":"		|
"&"		|
"="							{ return yytext[0]; }

{whitespace}			;	/* ignore */

 .						TSTRING(NOT_A_TOKEN)

%%


