%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "ast.h"
#include "tabela.h"
int yylex(void);
void yyerror(const char *mensagem);
extern FILE *yyin;
extern int yylineno;
extern char *yytext;
static No *raiz = NULL;

/* Contagem de erros semanticos e tipo da declaracao em andamento. */
static int erros_semanticos = 0;
static Tipo tipo_corrente = TIPO_INT;


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

/* ---- Analise semantica: escopo e tipos ---- */
static void erro_semantico(int linha, const char *fmt, ...) {
    va_list ap;
    erros_semanticos++;
    fprintf(stderr, "Erro semantico na linha %d: ", linha);
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fputc('\n', stderr);
}

/* Uso de um identificador: busca na tabela (escopo atual e externos) e devolve o
 * simbolo, ou NULL (com erro) se nao existir ou se for uma funcao. */
static Simbolo *buscar_variavel(const char *nome, int linha) {
    Simbolo *s = tabela_buscar(nome, tabela_escopo_atual());
    if (!s) {
        erro_semantico(linha, "identificador '%s' nao declarado", nome);
        return NULL;
    }
    if (s->categoria == CAT_FUNCAO) {
        erro_semantico(linha, "'%s' e uma funcao, nao uma variavel", nome);
        return NULL;
    }
    return s;
}

/* N_ID anotado com o tipo do simbolo (TIPO_ERRO se nao declarado). */
static No *no_id(int linha, const char *nome) {
    No *no = no_novo(linha, N_ID, nome, NULL, NULL, NULL);
    Simbolo *s = buscar_variavel(nome, linha);
    no->tipo = s ? s->tipo : TIPO_ERRO;
    return no;
}

/* Verifica se um valor de tipo 'origem' pode ser atribuido a 'destino'. */
static void checar_atribuicao(int linha, const char *nome, Tipo destino, Tipo origem) {
    if (destino == TIPO_ERRO || origem == TIPO_ERRO) return;
    if (tipos_compativeis(destino, origem)) return;
    erro_semantico(linha, "tipos incompativeis na atribuicao a '%s' (%s = %s)",
                   nome, tipo_nome(destino), tipo_nome(origem));
}

/* Operacao binaria: o tipo vem de tipo_resultado_binop; aqui so se reporta o erro. */
static No *no_binop(int linha, const char *op, No *a, No *b) {
    No *no = no_novo(linha, N_BINOP, op, a, b, NULL);
    no->tipo = tipo_resultado_binop(op, a->tipo, b->tipo);
    if (no->tipo == TIPO_ERRO && a->tipo != TIPO_ERRO && b->tipo != TIPO_ERRO)
        erro_semantico(linha, "tipos incompativeis para '%s' (%s e %s)", op, tipo_nome(a->tipo), tipo_nome(b->tipo));
    return no;
}

/* Operador unario (+, -, !) exige operando numerico. */
static No *no_unop(int linha, const char *op, No *a) {
    No *no = no_novo(linha, N_UNOP, op, a, NULL, NULL);
    no->tipo = tipo_resultado_unop(op, a->tipo);
    if (no->tipo == TIPO_ERRO && a->tipo != TIPO_ERRO)
        erro_semantico(linha, "operando invalido para '%s' (%s)", op, tipo_nome(a->tipo));
    return no;
}

/* ++ / -- (prefixo ou posfixo) sobre variavel numerica. */
static No *no_incdec(int linha, TipoNo kind, const char *op, const char *nome) {
    No *id = no_id(linha, nome);
    No *no = no_novo(linha, kind, op, id, NULL, NULL);
    if (id->tipo == TIPO_ERRO) no->tipo = TIPO_ERRO;
    else if (!tipo_numerico(id->tipo)) {
        erro_semantico(linha, "operador '%s' exige variavel numerica ('%s' e %s)", op, nome, tipo_nome(id->tipo));
        no->tipo = TIPO_ERRO;
    } else no->tipo = id->tipo;
    return no;
}

/* Condicao de if/while: nao pode ser string/void. */
static void checar_condicao(int linha, const No *cond) {
    if (cond->tipo == TIPO_ERRO || tipo_numerico(cond->tipo)) return;
    erro_semantico(linha, "condicao invalida (%s)", tipo_nome(cond->tipo));
}

/* Declara a funcao no escopo atual e abre o escopo dela (parametros + corpo). */
static void abrir_funcao(const char *nome, Tipo retorno, int linha) {
    declarar(nome, CAT_FUNCAO, retorno, linha);
    tabela_entrar_escopo(nome);
}
%}
%code requires { #include "ast.h" }
%locations
%define parse.error detailed
%union { int ival; double dval; char *sval; No *no; }

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
%type <no> programa comando bloco comando_if comando_while comando_print declaracao tipo
%type <no> lista_declaradores declarador atribuicao funcao cabecalho_funcao
%type <no> parametros lista_parametros parametro expressao argumentos_print
%destructor { ast_liberar($$); } <no>

%left OR
%left AND
%left EQ DIFER
%left MENOR MENEQ MAIOR MAIOREQ
%left PLUS MINUS
%left TIMES DIVIDE MOD
%precedence UPLUS UMINUS NOT
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
    PONTOVIR { $$ = NULL; }
  | declaracao PONTOVIR { $$ = $1; }
  | atribuicao PONTOVIR { $$ = $1; }
  | expressao PONTOVIR { $$ = no_novo(@$.first_line, N_EXPR_STMT, NULL, $1, NULL, NULL); }
  | bloco { $$ = $1; }
  | comando_if { $$ = $1; }
  | comando_while { $$ = $1; }
  | comando_print PONTOVIR { $$ = $1; }
  | KW_RETURN PONTOVIR { $$ = no_novo(@$.first_line, N_RETURN, NULL, NULL, NULL, NULL); }
  | KW_RETURN expressao PONTOVIR { $$ = no_novo(@$.first_line, N_RETURN, NULL, $2, NULL, NULL); }
  | funcao { $$ = $1; }
  ;
bloco:
    LCHAVE { tabela_entrar_escopo("bloco"); } programa RCHAVE
      { tabela_sair_escopo(); $$ = no_novo(@$.first_line, N_BLOCO, NULL, $3, NULL, NULL); }
  ;
comando_if:
    KW_IF LPAREN expressao RPAREN comando %prec THEN
      { checar_condicao(@3.first_line, $3); $$ = no_novo(@$.first_line, N_IF, NULL, $3, $5, NULL); }
  | KW_IF LPAREN expressao RPAREN comando KW_ELSE comando
      { checar_condicao(@3.first_line, $3); $$ = no_novo(@$.first_line, N_IF, NULL, $3, $5, $7); }
  ;

comando_while:
    KW_WHILE LPAREN expressao RPAREN comando
      { checar_condicao(@3.first_line, $3); $$ = no_novo(@$.first_line, N_WHILE, NULL, $3, $5, NULL); }
  ;
comando_print: KW_PRINT LPAREN argumentos_print RPAREN { $$ = no_novo(@$.first_line, N_PRINT, NULL, $3, NULL, NULL); } ;
argumentos_print:
    expressao { $$ = $1; }
  | argumentos_print VIRGULA expressao { $$ = no_lista_add($1, $3); }
  ;

/* Declaracoes de variaveis e atribuicao */
declaracao: tipo lista_declaradores { $$ = no_novo(@$.first_line, N_DECL, NULL, $1, $2, NULL); } ;
tipo:
    KW_INT { $$ = no_novo(@$.first_line, N_TIPO, "int", NULL, NULL, NULL); tipo_corrente = $$->tipo; }
  | KW_FLOAT { $$ = no_novo(@$.first_line, N_TIPO, "float", NULL, NULL, NULL); tipo_corrente = $$->tipo; }
  | KW_DOUBLE { $$ = no_novo(@$.first_line, N_TIPO, "double", NULL, NULL, NULL); tipo_corrente = $$->tipo; }
  | KW_CHAR { $$ = no_novo(@$.first_line, N_TIPO, "char", NULL, NULL, NULL); tipo_corrente = $$->tipo; }
  | KW_STRING { $$ = no_novo(@$.first_line, N_TIPO, "string", NULL, NULL, NULL); tipo_corrente = $$->tipo; }
  ;
lista_declaradores:
    declarador { $$ = $1; }
  | lista_declaradores VIRGULA declarador { $$ = no_lista_add($1, $3); }
  ;
declarador:
    IDENT { declarar($1, CAT_VARIAVEL, tipo_corrente, @1.first_line);
            $$ = no_novo(@$.first_line, N_DECLARADOR, $1, NULL, NULL, NULL); free($1); }
  | IDENT ASSIGN expressao { declarar($1, CAT_VARIAVEL, tipo_corrente, @1.first_line);
            checar_atribuicao(@1.first_line, $1, tipo_corrente, $3->tipo);
            $$ = no_novo(@$.first_line, N_DECLARADOR, $1, $3, NULL, NULL); free($1); }
  ;
atribuicao:
    IDENT ASSIGN expressao
      { Simbolo *s = buscar_variavel($1, @1.first_line);
        $$ = no_novo(@$.first_line, N_ATRIB, $1, $3, NULL, NULL);
        if (s) { checar_atribuicao(@1.first_line, $1, s->tipo, $3->tipo); $$->tipo = s->tipo; }
        else $$->tipo = TIPO_ERRO;
        free($1); }
  ;

/* Definicao de funcoes */
funcao:
    cabecalho_funcao parametros RPAREN LCHAVE programa RCHAVE
      { tabela_sair_escopo();
        $1->filho[1] = $2;
        $1->filho[2] = no_novo(@4.first_line, N_BLOCO, NULL, $5, NULL, NULL);
        $$ = $1; }
  ;
/* O escopo da funcao e aberto no cabecalho: parametros e corpo compartilham o mesmo escopo. */
cabecalho_funcao:
    tipo IDENT LPAREN
      { abrir_funcao($2, $1->tipo, @2.first_line);
        $$ = no_novo(@2.first_line, N_FUNCAO, $2, $1, NULL, NULL); free($2); }
  | KW_VOID IDENT LPAREN
      { abrir_funcao($2, TIPO_VOID, @2.first_line);
        $$ = no_novo(@2.first_line, N_FUNCAO, $2,
                     no_novo(@1.first_line, N_TIPO, "void", NULL, NULL, NULL), NULL, NULL);
        free($2); }
  ;
parametros: %empty { $$ = NULL; } | KW_VOID { $$ = NULL; } | lista_parametros { $$ = $1; } ;
lista_parametros:
    parametro { $$ = $1; }
  | lista_parametros VIRGULA parametro { $$ = no_lista_add($1, $3); }
  ;
parametro:
    tipo IDENT { declarar($2, CAT_PARAMETRO, $1->tipo, @2.first_line);
                 $$ = no_novo(@$.first_line, N_PARAM, $2, $1, NULL, NULL); free($2); }
  ;

/* Expressoes */
expressao:
    NUMBER { $$ = no_num(@$.first_line, $1); }
  | CHARLIT { $$ = no_char(@$.first_line, $1); }
  | STRINGLIT { $$ = no_novo(@$.first_line, N_STRING, $1, NULL, NULL, NULL); free($1); }
  | IDENT { $$ = no_id(@$.first_line, $1); free($1); }
  | LPAREN expressao RPAREN { $$ = $2; }
  | PLUS expressao %prec UPLUS { $$ = no_unop(@$.first_line, "+", $2); }
  | MINUS expressao %prec UMINUS { $$ = no_unop(@$.first_line, "-", $2); }
  | NOT expressao { $$ = no_unop(@$.first_line, "!", $2); }
  | INCRE IDENT { $$ = no_incdec(@$.first_line, N_PREINC, "++", $2); free($2); }
  | DECRE IDENT { $$ = no_incdec(@$.first_line, N_PREINC, "--", $2); free($2); }
  | IDENT INCRE { $$ = no_incdec(@$.first_line, N_POSINC, "++", $1); free($1); }
  | IDENT DECRE { $$ = no_incdec(@$.first_line, N_POSINC, "--", $1); free($1); }
  | expressao PLUS expressao { $$ = no_binop(@$.first_line, "+", $1, $3); }
  | expressao MINUS expressao { $$ = no_binop(@$.first_line, "-", $1, $3); }
  | expressao TIMES expressao { $$ = no_binop(@$.first_line, "*", $1, $3); }
  | expressao DIVIDE expressao { $$ = no_binop(@$.first_line, "/", $1, $3); }
  | expressao MOD expressao { $$ = no_binop(@$.first_line, "%", $1, $3); }
  | expressao MENOR expressao { $$ = no_binop(@$.first_line, "<", $1, $3); }
  | expressao MENEQ expressao { $$ = no_binop(@$.first_line, "<=", $1, $3); }
  | expressao MAIOR expressao { $$ = no_binop(@$.first_line, ">", $1, $3); }
  | expressao MAIOREQ expressao { $$ = no_binop(@$.first_line, ">=", $1, $3); }
  | expressao EQ expressao { $$ = no_binop(@$.first_line, "==", $1, $3); }
  | expressao DIFER expressao { $$ = no_binop(@$.first_line, "!=", $1, $3); }
  | expressao AND expressao { $$ = no_binop(@$.first_line, "&&", $1, $3); }
  | expressao OR expressao { $$ = no_binop(@$.first_line, "||", $1, $3); }
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
        puts("Arvore sintatica abstrata:");
        ast_imprimir(raiz, 0);
        tabela_imprimir();
        if (erros_semanticos == 0) status = EXIT_SUCCESS;
        else fprintf(stderr, "%d erro(s) semantico(s).\n", erros_semanticos);
    }
    ast_liberar(raiz);
    tabela_liberar();
    return status;
}
