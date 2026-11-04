#ifndef AST_H
#define AST_H

typedef enum {
    N_PROGRAMA, N_BLOCO, N_DECL, N_DECLARADOR, N_TIPO, N_ATRIB, N_EXPR_STMT,
    N_IF, N_RETURN, N_FUNCAO, N_PARAM,
    N_BINOP, N_UNOP, N_PREINC, N_POSINC,
    N_NUM, N_CHAR, N_STRING, N_ID
} TipoNo;

/* Tipo de dados anotado no no. A analise semantica preenche/atualiza este
 * campo; ate la os nos ficam com TIPO_DESCONHECIDO (exceto N_TIPO, N_CHAR e
 * N_STRING, cujo tipo ja e conhecido na construcao). */
typedef enum {
    TIPO_DESCONHECIDO, TIPO_INT, TIPO_FLOAT, TIPO_DOUBLE, TIPO_CHAR,
    TIPO_STRING, TIPO_VOID, TIPO_ERRO
} Tipo;

/*
 * Layout dos nos (filho[0..2]; "prox" encadeia irmaos em listas):
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
 * Listas (comandos, declaradores, parametros) sao a cadeia "prox" a partir do
 * primeiro elemento; um filho que aponta para lista deve ser percorrido com
 * "for (n = filho; n; n = n->prox)".
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

#endif
