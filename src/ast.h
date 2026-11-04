#ifndef AST_H
#define AST_H

typedef enum {
    N_PROGRAMA, N_BLOCO, N_DECL, N_DECLARADOR, N_TIPO, N_ATRIB, N_EXPR_STMT,
    N_IF, N_RETURN, N_FUNCAO, N_PARAM,
    N_BINOP, N_UNOP, N_PREINC, N_POSINC,
    N_NUM, N_CHAR, N_STRING, N_ID
} TipoNo;

typedef struct No {
    TipoNo tipo;
    int linha;              /* linha de origem (yylineno) */
    char *texto;            /* nome, literal ou operador; NULL se nao se aplica */
    double num;             /* valor de N_NUM / N_CHAR */
    struct No *filho[3];    /* if: cond, then, else; binop: esq, dir */
    struct No *prox;        /* proximo irmao (listas de comandos, params, declaradores) */
} No;

No *no_novo(TipoNo tipo, const char *texto, No *a, No *b, No *c);
No *no_num(double valor);
No *no_char(int valor);
No *no_lista_add(No *lista, No *novo);
void ast_imprimir(const No *no, int nivel);
void ast_liberar(No *no);

#endif
