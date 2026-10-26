%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"
%}

%option yylineno noyywrap noinput nounput
%x COMENTARIO

%%

if          { return KW_IF; }
while       { return KW_WHILE; }
for         { return KW_FOR; }
else        { return KW_ELSE; }
return      { return KW_RETURN; }
print       { return KW_PRINT; }

int         { return KW_INT; }
float       { return KW_FLOAT; }
char        { return KW_CHAR; }
string      { return KW_STRING; }
double      { return KW_DOUBLE; }
void        { return KW_VOID; }

"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LCHAVE; }
"}"         { return RCHAVE; }
"["         { return LCOLCH; }
"]"         { return RCOLCH; }
"<="        { return MENEQ; }
">="        { return MAIOREQ; }
"!="        { return DIFER; }
"=="        { return EQ; }
"++"        { return INCRE; }
"--"        { return DECRE; }
"="         { return ASSIGN; }
"<"         { return MENOR; }
">"         { return MAIOR; }
";"         { return PONTOVIR; }
","         { return VIRGULA; }

"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return TIMES; }
"/"         { return DIVIDE; }
"%"         { return MOD; }
"&&"        { return AND; }
"||"        { return OR; }
"!"         { return NOT; }

"//".*                       { /* Ignorar comentarios de linha */ }
"/*"                         { BEGIN(COMENTARIO); }
<COMENTARIO>"*/"             { BEGIN(INITIAL); }
<COMENTARIO>[^*\n]+          { /* Ignorar conteudo do comentario */ }
<COMENTARIO>"*"              { /* Ignorar asterisco isolado */ }
<COMENTARIO>\n               { /* yylineno atualizado pelo Flex */ }
<COMENTARIO><<EOF>>          {
    fprintf(stderr, "Erro lexico na linha %d: comentario de bloco nao encerrado\n", yylineno);
    BEGIN(INITIAL);
    return INVALID;
}
^#.*                         { /* Ignorar diretivas de pre-processador (#include, #define, ...) */ }

[a-zA-Z_][a-zA-Z0-9_]*  { yylval.sval = strdup(yytext); return IDENT; }
(([0-9]+\.[0-9]*|\.[0-9]+)([eE][+-]?[0-9]+)?|[0-9]+[eE][+-]?[0-9]+)[fFlL]?|[0-9]+      { yylval.dval = atof(yytext); return NUMBER; }
\"([^\"\\\r\n]|\\.)*\"      { yylval.sval = strdup(yytext); return STRINGLIT; }
\'([^\'\\\r\n]|\\.)\'       { yylval.ival = yytext[1]; return CHARLIT; }

[ \t\r\n]+  { /* Ignorar espacos em branco */ }

.  {
    fprintf(stderr, "Erro lexico na linha %d: caractere nao reconhecido '%s'\n",
            yylineno, yytext);
    return INVALID;
}

%%
