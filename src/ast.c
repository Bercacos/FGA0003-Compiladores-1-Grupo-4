#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylineno;

static const char *nomes[] = {
    [N_PROGRAMA] = "Programa", [N_BLOCO] = "Bloco", [N_DECL] = "Decl",
    [N_DECLARADOR] = "Declarador", [N_TIPO] = "Tipo", [N_ATRIB] = "Atrib",
    [N_EXPR_STMT] = "ExprStmt", [N_IF] = "If", [N_RETURN] = "Return",
    [N_FUNCAO] = "Funcao", [N_PARAM] = "Param", [N_BINOP] = "BinOp",
    [N_UNOP] = "UnOp", [N_PREINC] = "PreInc", [N_POSINC] = "PosInc",
    [N_NUM] = "Num", [N_CHAR] = "Char", [N_STRING] = "String", [N_ID] = "Id",
};

static void *alocar(size_t tamanho) {
    void *p = calloc(1, tamanho);
    if (!p) {
        perror("calloc");
        exit(EXIT_FAILURE);
    }
    return p;
}

No *no_novo(TipoNo tipo, const char *texto, No *a, No *b, No *c) {
    No *no = alocar(sizeof *no);
    no->tipo = tipo;
    no->linha = yylineno;
    if (texto) {
        no->texto = strdup(texto);
        if (!no->texto) {
            perror("strdup");
            exit(EXIT_FAILURE);
        }
    }
    no->filho[0] = a;
    no->filho[1] = b;
    no->filho[2] = c;
    return no;
}

No *no_num(double valor) {
    No *no = no_novo(N_NUM, NULL, NULL, NULL, NULL);
    no->num = valor;
    return no;
}

No *no_char(int valor) {
    No *no = no_novo(N_CHAR, NULL, NULL, NULL, NULL);
    no->num = valor;
    return no;
}

No *no_lista_add(No *lista, No *novo) {
    if (!lista) return novo;
    No *ultimo = lista;
    while (ultimo->prox) ultimo = ultimo->prox;
    ultimo->prox = novo;
    return lista;
}

void ast_imprimir(const No *no, int nivel) {
    for (; no; no = no->prox) {
        printf("%*s%s", nivel * 2, "", nomes[no->tipo]);
        if (no->tipo == N_NUM)
            printf(" %g", no->num);
        else if (no->tipo == N_CHAR)
            printf(" '%c'", (int)no->num);
        else if (no->texto)
            printf(" %s", no->texto);
        printf("  (linha %d)\n", no->linha);
        for (int i = 0; i < 3; i++)
            ast_imprimir(no->filho[i], nivel + 1);
    }
}

void ast_liberar(No *no) {
    while (no) {
        No *prox = no->prox;
        for (int i = 0; i < 3; i++)
            ast_liberar(no->filho[i]);
        free(no->texto);
        free(no);
        no = prox;
    }
}
