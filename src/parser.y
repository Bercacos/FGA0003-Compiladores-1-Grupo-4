%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
int yylex(void);
void yyerror(const char *mensagem);
extern FILE *yyin;
extern int yylineno;
extern char *yytext;
static No *raiz = NULL;
%}
%code requires { #include "ast.h" }
%define parse.error detailed
%locations
%union { int ival; double dval; char *sval; No *no; }

%token KW_IF KW_WHILE KW_FOR KW_ELSE KW_RETURN
%token KW_INT KW_FLOAT KW_CHAR KW_STRING KW_DOUBLE KW_VOID
%token LPAREN RPAREN LCHAVE RCHAVE LCOLCH RCOLCH
%token MENEQ MAIOREQ DIFER EQ INCRE DECRE ASSIGN MENOR MAIOR
%token PONTOVIR VIRGULA PLUS MINUS TIMES DIVIDE MOD
%token <sval> IDENT STRINGLIT
%token <dval> NUMBER
%token <ival> CHARLIT
%destructor { free($$); } <sval>

%type <no> programa comando bloco comando_if declaracao tipo
%type <no> lista_declaradores declarador atribuicao funcao
%type <no> parametros lista_parametros parametro expressao
%destructor { ast_liberar($$); } <no>

%left EQ DIFER
%left MENOR MENEQ MAIOR MAIOREQ
%left PLUS MINUS
%left TIMES DIVIDE MOD
%precedence UPLUS UMINUS
%precedence THEN
%precedence KW_ELSE

%start unidade
%%

unidade: programa { raiz = no_novo(@$.first_line, N_PROGRAMA, NULL, $1, NULL, NULL); } ;

/* Estrutura do programa e comandos */
programa: %empty { $$ = NULL; }
  | programa comando { $$ = no_lista_add($1, $2); }
  ;
comando:
    declaracao PONTOVIR { $$ = $1; }
  | atribuicao PONTOVIR { $$ = $1; }
  | expressao PONTOVIR { $$ = no_novo(@$.first_line, N_EXPR_STMT, NULL, $1, NULL, NULL); }
  | bloco { $$ = $1; }
  | comando_if { $$ = $1; }
  | KW_RETURN PONTOVIR { $$ = no_novo(@$.first_line, N_RETURN, NULL, NULL, NULL, NULL); }
  | KW_RETURN expressao PONTOVIR { $$ = no_novo(@$.first_line, N_RETURN, NULL, $2, NULL, NULL); }
  | funcao { $$ = $1; }
  ;
bloco: LCHAVE programa RCHAVE { $$ = no_novo(@$.first_line, N_BLOCO, NULL, $2, NULL, NULL); } ;
comando_if:
    KW_IF LPAREN expressao RPAREN comando %prec THEN
      { $$ = no_novo(@$.first_line, N_IF, NULL, $3, $5, NULL); }
  | KW_IF LPAREN expressao RPAREN comando KW_ELSE comando
      { $$ = no_novo(@$.first_line, N_IF, NULL, $3, $5, $7); }
  ;

/* Declaracoes de variaveis e atribuicao */
declaracao: tipo lista_declaradores { $$ = no_novo(@$.first_line, N_DECL, NULL, $1, $2, NULL); } ;
tipo:
    KW_INT { $$ = no_novo(@$.first_line, N_TIPO, "int", NULL, NULL, NULL); }
  | KW_FLOAT { $$ = no_novo(@$.first_line, N_TIPO, "float", NULL, NULL, NULL); }
  | KW_DOUBLE { $$ = no_novo(@$.first_line, N_TIPO, "double", NULL, NULL, NULL); }
  | KW_CHAR { $$ = no_novo(@$.first_line, N_TIPO, "char", NULL, NULL, NULL); }
  | KW_STRING { $$ = no_novo(@$.first_line, N_TIPO, "string", NULL, NULL, NULL); }
  ;
lista_declaradores:
    declarador { $$ = $1; }
  | lista_declaradores VIRGULA declarador { $$ = no_lista_add($1, $3); }
  ;
declarador:
    IDENT { $$ = no_novo(@$.first_line, N_DECLARADOR, $1, NULL, NULL, NULL); free($1); }
  | IDENT ASSIGN expressao { $$ = no_novo(@$.first_line, N_DECLARADOR, $1, $3, NULL, NULL); free($1); }
  ;
atribuicao: IDENT ASSIGN expressao { $$ = no_novo(@$.first_line, N_ATRIB, $1, $3, NULL, NULL); free($1); } ;

/* Definicao de funcoes */
funcao:
    tipo IDENT LPAREN parametros RPAREN bloco
      { $$ = no_novo(@$.first_line, N_FUNCAO, $2, $1, $4, $6); free($2); }
  | KW_VOID IDENT LPAREN parametros RPAREN bloco
      { $$ = no_novo(@$.first_line, N_FUNCAO, $2, no_novo(@$.first_line, N_TIPO, "void", NULL, NULL, NULL), $4, $6);
        free($2); }
  ;
parametros: %empty { $$ = NULL; } | KW_VOID { $$ = NULL; } | lista_parametros { $$ = $1; } ;
lista_parametros:
    parametro { $$ = $1; }
  | lista_parametros VIRGULA parametro { $$ = no_lista_add($1, $3); }
  ;
parametro: tipo IDENT { $$ = no_novo(@$.first_line, N_PARAM, $2, $1, NULL, NULL); free($2); } ;

/* Expressoes */
expressao:
    NUMBER { $$ = no_num(@$.first_line, $1); }
  | CHARLIT { $$ = no_char(@$.first_line, $1); }
  | STRINGLIT { $$ = no_novo(@$.first_line, N_STRING, $1, NULL, NULL, NULL); free($1); }
  | IDENT { $$ = no_novo(@$.first_line, N_ID, $1, NULL, NULL, NULL); free($1); }
  | LPAREN expressao RPAREN { $$ = $2; }
  | PLUS expressao %prec UPLUS { $$ = no_novo(@$.first_line, N_UNOP, "+", $2, NULL, NULL); }
  | MINUS expressao %prec UMINUS { $$ = no_novo(@$.first_line, N_UNOP, "-", $2, NULL, NULL); }
  | INCRE IDENT { $$ = no_novo(@$.first_line, N_PREINC, "++", no_novo(@$.first_line, N_ID, $2, NULL, NULL, NULL), NULL, NULL); free($2); }
  | DECRE IDENT { $$ = no_novo(@$.first_line, N_PREINC, "--", no_novo(@$.first_line, N_ID, $2, NULL, NULL, NULL), NULL, NULL); free($2); }
  | IDENT INCRE { $$ = no_novo(@$.first_line, N_POSINC, "++", no_novo(@$.first_line, N_ID, $1, NULL, NULL, NULL), NULL, NULL); free($1); }
  | IDENT DECRE { $$ = no_novo(@$.first_line, N_POSINC, "--", no_novo(@$.first_line, N_ID, $1, NULL, NULL, NULL), NULL, NULL); free($1); }
  | expressao PLUS expressao { $$ = no_novo(@$.first_line, N_BINOP, "+", $1, $3, NULL); }
  | expressao MINUS expressao { $$ = no_novo(@$.first_line, N_BINOP, "-", $1, $3, NULL); }
  | expressao TIMES expressao { $$ = no_novo(@$.first_line, N_BINOP, "*", $1, $3, NULL); }
  | expressao DIVIDE expressao { $$ = no_novo(@$.first_line, N_BINOP, "/", $1, $3, NULL); }
  | expressao MOD expressao { $$ = no_novo(@$.first_line, N_BINOP, "%", $1, $3, NULL); }
  | expressao MENOR expressao { $$ = no_novo(@$.first_line, N_BINOP, "<", $1, $3, NULL); }
  | expressao MENEQ expressao { $$ = no_novo(@$.first_line, N_BINOP, "<=", $1, $3, NULL); }
  | expressao MAIOR expressao { $$ = no_novo(@$.first_line, N_BINOP, ">", $1, $3, NULL); }
  | expressao MAIOREQ expressao { $$ = no_novo(@$.first_line, N_BINOP, ">=", $1, $3, NULL); }
  | expressao EQ expressao { $$ = no_novo(@$.first_line, N_BINOP, "==", $1, $3, NULL); }
  | expressao DIFER expressao { $$ = no_novo(@$.first_line, N_BINOP, "!=", $1, $3, NULL); }
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
        puts("Arvore sintatica abstrata:");
        ast_imprimir(raiz, 0);
        ast_liberar(raiz);
        return EXIT_SUCCESS;
    }
    return EXIT_FAILURE;
}
