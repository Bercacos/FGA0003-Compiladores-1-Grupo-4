%{
#include <stdio.h>
%}

/* Definições de padrões de token e ações */
%%

if          { printf("KW_IF\n"); }
while       { printf("KW_WHILE\n"); }
for         { printf("KW_FOR\n"); }
else        { printf("KW_ELSE\n"); }
return      { printf("KW_RETURN\n"); }

"("         { printf("LPAREN\n"); }
")"         { printf("RPAREN\n"); }
"{"         { printf("LCHAVE\n"); }
"}"         { printf("RCHAVE\n"); }
"["         { printf("LCOLCH\n"); }
"]"         { printf("RCOLCH\n"); }
"<="        { printf("MENEQ\n");  }
">="        { printf("MAIOREQ\n");}
"!="        { printf("DIFER\n"); }
"=="        { printf("EQ\n"); }
"++"        { printf("INCRE\n"); }
"--"        { printf("DECRE\n"); }
"="         { printf("ASSIGN\n"); }
"<"         { printf("MENOR\n");  }
">"         { printf("MAIOR\n");  }
";"         { printf("PONTOVIR\n"); }
","         { printf("VIRGULA\n"); }



int         { printf("KW_INT\n"); }
float       { printf("KW_FLOAT\n"); }
char        { printf("KW_CHAR\n"); }
string      { printf("KW_STRING\n"); }
double      { printf("KW_DOUBLE\n"); }
void        { printf("KW_VOID\n"); }


"//".*     { /* Ignorar comentários de linha */ }

"/*"([^*]|\*+[^*/])*\*+\/    { /* Ignorar comentários de bloco */ }

[a-zA-Z_][a-zA-Z0-9_]*  { printf("IDENT(%s)\n", yytext); }

[0-9]+(\.[0-9]+)?  { printf("NUMBER(%s)\n", yytext); }

\"([^\"\\]|\\.)*\"  { printf("STRING(%s)\n", yytext); }

\'([^\'\\]|\\.)\'   { printf("CHAR(%s)\n", yytext); }



[+\-*/]   { printf("OPERATOR(%s)\n", yytext); }
 

[ \t\n]+  { /* Não faz nada */ }

.  { printf("UNKNOWN(%s)\n", yytext); }

%%

/* Função auxiliar do Flex (quando termina o arquivo de entrada) */
int yywrap(void) {
    return 1;
}

/* Função principal: executa o analisador léxico */
int main(void) {
    yylex();
    return 0;
}
