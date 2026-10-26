%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
void yyerror(const char *mensagem);
extern FILE *yyin;
extern int yylineno;
extern char *yytext;
%}
%define parse.error detailed
%union { int ival; double dval; char *sval; }

%token KW_IF KW_WHILE KW_FOR KW_ELSE KW_RETURN KW_PRINT
%token KW_INT KW_FLOAT KW_CHAR KW_STRING KW_DOUBLE KW_VOID
%token LPAREN RPAREN LCHAVE RCHAVE LCOLCH RCOLCH
%token MENEQ MAIOREQ DIFER EQ INCRE DECRE ASSIGN MENOR MAIOR
%token PONTOVIR VIRGULA PLUS MINUS TIMES DIVIDE MOD
%token AND OR NOT INVALID
%token <sval> IDENT STRINGLIT
%token <dval> NUMBER
%token <ival> CHARLIT
%destructor { free($$); } <sval>

%left OR
%left AND
%left EQ DIFER
%left MENOR MENEQ MAIOR MAIOREQ
%left PLUS MINUS
%left TIMES DIVIDE MOD
%precedence UPLUS UMINUS NOT
%precedence THEN
%precedence KW_ELSE

%start programa
%%

/* Estrutura do programa e comandos */
programa: %empty | programa comando ;
comando:
    PONTOVIR
  | declaracao PONTOVIR
  | atribuicao PONTOVIR
  | expressao PONTOVIR
  | bloco
  | comando_if
  | comando_while
  | comando_print PONTOVIR
  | KW_RETURN PONTOVIR
  | KW_RETURN expressao PONTOVIR
  | funcao
  ;
bloco: LCHAVE programa RCHAVE ;
comando_if:
    KW_IF LPAREN expressao RPAREN comando %prec THEN
  | KW_IF LPAREN expressao RPAREN comando KW_ELSE comando
  ;

comando_while: KW_WHILE LPAREN expressao RPAREN comando ;
comando_print: KW_PRINT LPAREN argumentos_print RPAREN ;
argumentos_print: expressao | argumentos_print VIRGULA expressao ;

/* Declaracoes de variaveis e atribuicao */
declaracao: tipo lista_declaradores ;
tipo: KW_INT | KW_FLOAT | KW_DOUBLE | KW_CHAR | KW_STRING ;
lista_declaradores: declarador | lista_declaradores VIRGULA declarador ;
declarador:
    IDENT { free($1); }
  | IDENT ASSIGN expressao { free($1); }
  ;
atribuicao: IDENT ASSIGN expressao { free($1); } ;

/* Definicao de funcoes */
funcao:
    tipo IDENT LPAREN parametros RPAREN bloco { free($2); }
  | KW_VOID IDENT LPAREN parametros RPAREN bloco { free($2); }
  ;
parametros: %empty | KW_VOID | lista_parametros ;
lista_parametros: parametro | lista_parametros VIRGULA parametro ;
parametro: tipo IDENT { free($2); } ;

/* Expressoes */
expressao:
    NUMBER
  | CHARLIT
  | STRINGLIT { free($1); }
  | IDENT { free($1); }
  | LPAREN expressao RPAREN
  | PLUS expressao %prec UPLUS
  | MINUS expressao %prec UMINUS
  | NOT expressao
  | INCRE IDENT { free($2); }
  | DECRE IDENT { free($2); }
  | IDENT INCRE { free($1); }
  | IDENT DECRE { free($1); }
  | expressao PLUS expressao
  | expressao MINUS expressao
  | expressao TIMES expressao
  | expressao DIVIDE expressao
  | expressao MOD expressao
  | expressao MENOR expressao
  | expressao MENEQ expressao
  | expressao MAIOR expressao
  | expressao MAIOREQ expressao
  | expressao EQ expressao
  | expressao DIFER expressao
  | expressao AND expressao
  | expressao OR expressao
  ;
%%

void yyerror(const char *mensagem) {
    fprintf(stderr, "Erro sintatico na linha %d, proximo a '%s': %s\n",
            yylineno, yytext ? yytext : "fim do arquivo", mensagem);
}

int main(int argc, char **argv) {
    if (argc > 2) {
        fprintf(stderr, "Uso: %s [arquivo]\n", argv[0]);
        return EXIT_FAILURE;
    }
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
        if (yyin == NULL) {
            perror(argv[1]);
            return EXIT_FAILURE;
        }
    }
    int resultado = yyparse();
    if (argc == 2) fclose(yyin);
    if (resultado == 0) {
        puts("Analise sintatica concluida com sucesso.");
        return EXIT_SUCCESS;
    }
    return EXIT_FAILURE;
}
