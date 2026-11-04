%{
#include <stdio.h>
#include <stdlib.h>
#include "tabela.h"
int yylex(void);
void yyerror(const char *mensagem);
extern FILE *yyin;
extern int yylineno;
extern char *yytext;

/* Contagem de erros semanticos e tipo da declaracao em andamento. */
static int erros_semanticos = 0;
static Tipo tipo_corrente = TIPO_INT;

static Tipo definir_tipo(Tipo tipo) {
    tipo_corrente = tipo;
    return tipo;
}

/* Registra o simbolo no escopo atual; reporta redeclaracao. */
static void declarar(const char *nome, Categoria categoria, Tipo tipo, int linha) {
    int escopo = tabela_escopo_atual();
    TabelaStatus status = tabela_inserir(nome, categoria, tipo, escopo, linha);
    if (status == TABELA_OK) return;
    erros_semanticos++;
    if (status == TABELA_REDECLARADO) {
        Simbolo *anterior = tabela_buscar_no_escopo(nome, escopo);
        fprintf(stderr, "Erro semantico na linha %d: '%s' ja declarado neste escopo (linha %d)\n",
                linha, nome, anterior ? anterior->linha : 0);
    } else {
        fprintf(stderr, "Erro semantico na linha %d: nao foi possivel declarar '%s' (%s)\n",
                linha, nome, tabela_status_para_texto(status));
    }
}

/* Declara a funcao no escopo atual e abre o escopo dela (parametros + corpo). */
static void abrir_funcao(const char *nome, Tipo retorno, int linha) {
    declarar(nome, CAT_FUNCAO, retorno, linha);
    tabela_entrar_escopo(nome);
}
%}
%code requires { #include "tipos.h" }
%locations
%define parse.error detailed
%union { int ival; double dval; char *sval; Tipo tipo; }

%token KW_IF KW_WHILE KW_FOR KW_ELSE KW_RETURN
%token KW_INT KW_FLOAT KW_CHAR KW_STRING KW_DOUBLE KW_VOID
%token LPAREN RPAREN LCHAVE RCHAVE LCOLCH RCOLCH
%token MENEQ MAIOREQ DIFER EQ INCRE DECRE ASSIGN MENOR MAIOR
%token PONTOVIR VIRGULA PLUS MINUS TIMES DIVIDE MOD
%token <sval> IDENT STRINGLIT
%token <dval> NUMBER
%token <ival> CHARLIT
%destructor { free($$); } <sval>
%type <tipo> tipo

%left EQ DIFER
%left MENOR MENEQ MAIOR MAIOREQ
%left PLUS MINUS
%left TIMES DIVIDE MOD
%precedence UPLUS UMINUS
%precedence THEN
%precedence KW_ELSE

%start programa
%%

/* Estrutura do programa e comandos */
programa: %empty | programa comando ;
comando:
    declaracao PONTOVIR
  | atribuicao PONTOVIR
  | expressao PONTOVIR
  | bloco
  | comando_if
  | KW_RETURN PONTOVIR
  | KW_RETURN expressao PONTOVIR
  | funcao
  ;
bloco:
    LCHAVE { tabela_entrar_escopo("bloco"); } programa RCHAVE { tabela_sair_escopo(); }
  ;
comando_if:
    KW_IF LPAREN expressao RPAREN comando %prec THEN
  | KW_IF LPAREN expressao RPAREN comando KW_ELSE comando
  ;

/* Declaracoes de variaveis e atribuicao */
declaracao: tipo lista_declaradores ;
tipo:
    KW_INT    { $$ = definir_tipo(TIPO_INT); }
  | KW_FLOAT  { $$ = definir_tipo(TIPO_FLOAT); }
  | KW_DOUBLE { $$ = definir_tipo(TIPO_DOUBLE); }
  | KW_CHAR   { $$ = definir_tipo(TIPO_CHAR); }
  | KW_STRING { $$ = definir_tipo(TIPO_STRING); }
  ;
lista_declaradores: declarador | lista_declaradores VIRGULA declarador ;
declarador:
    IDENT { declarar($1, CAT_VARIAVEL, tipo_corrente, @1.first_line); free($1); }
  | IDENT ASSIGN expressao { declarar($1, CAT_VARIAVEL, tipo_corrente, @1.first_line); free($1); }
  ;
atribuicao: IDENT ASSIGN expressao { free($1); } ;

/* Definicao de funcoes */
funcao:
    cabecalho_funcao parametros RPAREN LCHAVE programa RCHAVE { tabela_sair_escopo(); }
  ;
/* O escopo da funcao e aberto no cabecalho: parametros e corpo compartilham o mesmo escopo. */
cabecalho_funcao:
    tipo IDENT LPAREN { abrir_funcao($2, $1, @2.first_line); free($2); }
  | KW_VOID IDENT LPAREN { abrir_funcao($2, TIPO_VOID, @2.first_line); free($2); }
  ;
parametros: %empty | KW_VOID | lista_parametros ;
lista_parametros: parametro | lista_parametros VIRGULA parametro ;
parametro: tipo IDENT { declarar($2, CAT_PARAMETRO, $1, @2.first_line); free($2); } ;

/* Expressoes */
expressao:
    NUMBER
  | CHARLIT
  | STRINGLIT { free($1); }
  | IDENT { free($1); }
  | LPAREN expressao RPAREN
  | PLUS expressao %prec UPLUS
  | MINUS expressao %prec UMINUS
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
    tabela_iniciar();
    int resultado = yyparse();
    if (argc == 2) fclose(yyin);
    int status = EXIT_FAILURE;
    if (resultado == 0) {
        puts("Analise sintatica concluida com sucesso.");
        tabela_imprimir();
        if (erros_semanticos == 0) status = EXIT_SUCCESS;
        else fprintf(stderr, "%d erro(s) semantico(s).\n", erros_semanticos);
    }
    tabela_liberar();
    return status;
}
