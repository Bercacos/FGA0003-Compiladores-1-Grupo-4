#ifndef AST_H
#define AST_H

#include "tipos.h"

typedef enum {
    N_PROGRAMA, N_BLOCO, N_DECL, N_DECLARADOR, N_TIPO, N_ATRIB, N_EXPR_STMT,
    N_IF, N_WHILE, N_PRINT, N_RETURN, N_FUNCAO, N_PARAM,
    N_BINOP, N_UNOP, N_PREINC, N_POSINC,
    N_NUM, N_CHAR, N_STRING, N_ID
} TipoNo;

/*
 * Layout dos nos (filho[0..2]; "prox" encadeia irmaos em listas).
 * O tipo de dados anotado em cada no (campo "tipo", enum Tipo em tipos.h) e
 * preenchido pela analise semantica no parser; TIPO_ERRO marca expressoes
 * invalidas.
 *
 *  TipoNo         texto     filho[0]        filho[1]       filho[2]
 *  N_PROGRAMA     -         lista de cmds   -              -
 *  N_BLOCO        -         lista de cmds   -              -
 *  N_DECL         -         N_TIPO          lista de N_DECLARADOR (via prox) -
 *  N_DECLARADOR   nome      inicializador   -              -   (NULL se sem "=")
 *  N_TIPO         tipo      -               -              -   ("int", "void"...)
 *  N_ATRIB        nome      expressao       -              -
 *  N_EXPR_STMT    -         expressao       -              -
 *  N_IF           -         condicao        then           else (NULL se ausente)
 *  N_WHILE        -         condicao        corpo          -
 *  N_PRINT        -         lista de expr (via prox)       -              -
 *  N_RETURN       -         expressao/NULL  -              -
 *  N_FUNCAO       nome      N_TIPO retorno  lista N_PARAM  N_BLOCO corpo
 *  N_PARAM        nome      N_TIPO          -              -
 *  N_BINOP        operador  esquerda        direita        -
 *  N_UNOP         operador  operando        -              -
 *  N_PREINC       "++"/"--" N_ID            -              -
 *  N_POSINC       "++"/"--" N_ID            -              -
 *  N_NUM          -         -               -              -   (valor em "num")
 *  N_CHAR         -         -               -              -   (codigo em "num")
 *  N_STRING       literal (com aspas, como no fonte)
 *  N_ID           nome      -               -              -
 *
 * Listas (comandos, declaradores, parametros, argumentos de print) sao a
 * cadeia "prox" a partir do primeiro elemento; um filho que aponta para lista
 * deve ser percorrido com "for (n = filho; n; n = n->prox)".
 */
typedef struct No {
    TipoNo tipo_no;
    Tipo tipo;              /* tipo de dados anotado (semantica) */
    int linha;              /* linha de origem */
    char *texto;            /* nome, literal ou operador; NULL se nao se aplica */
    double num;             /* valor de N_NUM / codigo de N_CHAR */
    struct No *filho[3];
    struct No *prox;        /* proximo irmao em listas */
} No;

No *no_novo(int linha, TipoNo tipo_no, const char *texto, No *a, No *b, No *c);
No *no_num(int linha, double valor);
No *no_char(int linha, int valor);
No *no_lista_add(No *lista, No *novo);
const char *tipo_nome(Tipo tipo);
void ast_imprimir(const No *no, int nivel);
void ast_liberar(No *no);

/* Regras de tipos (usadas pela analise semantica no parser).
 * Tipos numericos: int, float, double e char (conversao implicita, como em C). */
int tipo_numerico(Tipo tipo);
/* 1 se um valor do tipo "origem" pode ser atribuido a "destino". */
int tipos_compativeis(Tipo destino, Tipo origem);
/* Tipo de "a op b" (op: + - * / % < <= > >= == != && ||); TIPO_ERRO se os
 * operandos forem invalidos para o operador. Se a ou b ja forem TIPO_ERRO, o
 * resultado tambem e TIPO_ERRO. */
Tipo tipo_resultado_binop(const char *op, Tipo a, Tipo b);
/* Tipo de "op a" (op: + - !); TIPO_ERRO se o operando nao for numerico. */
Tipo tipo_resultado_unop(const char *op, Tipo a);

#endif
