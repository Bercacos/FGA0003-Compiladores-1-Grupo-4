#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const char *nomes[] = {
    [N_PROGRAMA] = "Programa", [N_BLOCO] = "Bloco", [N_DECL] = "Decl",
    [N_DECLARADOR] = "Declarador", [N_TIPO] = "Tipo", [N_ATRIB] = "Atrib",
    [N_EXPR_STMT] = "ExprStmt", [N_IF] = "If", [N_WHILE] = "While", [N_PRINT] = "Print", [N_RETURN] = "Return",
    [N_FUNCAO] = "Funcao", [N_PARAM] = "Param", [N_BINOP] = "BinOp",
    [N_UNOP] = "UnOp", [N_PREINC] = "PreInc", [N_POSINC] = "PosInc",
    [N_NUM] = "Num", [N_CHAR] = "Char", [N_STRING] = "String", [N_ID] = "Id",
};

static const char *nomes_tipo[] = {
    [TIPO_DESCONHECIDO] = "?", [TIPO_INT] = "int", [TIPO_FLOAT] = "float",
    [TIPO_DOUBLE] = "double", [TIPO_CHAR] = "char", [TIPO_STRING] = "string",
    [TIPO_VOID] = "void", [TIPO_ERRO] = "erro",
};

const char *tipo_nome(Tipo tipo) { return nomes_tipo[tipo]; }

static Tipo tipo_de_nome(const char *nome) {
    for (Tipo t = TIPO_INT; t <= TIPO_VOID; t++)
        if (strcmp(nome, nomes_tipo[t]) == 0) return t;
    return TIPO_DESCONHECIDO;
}

static void *alocar(size_t tamanho) {
    void *p = calloc(1, tamanho);
    if (!p) {
        perror("calloc");
        exit(EXIT_FAILURE);
    }
    return p;
}

No *no_novo(int linha, TipoNo tipo_no, const char *texto, No *a, No *b, No *c) {
    No *no = alocar(sizeof *no);
    no->tipo_no = tipo_no;
    no->linha = linha;
    if (texto) {
        no->texto = strdup(texto);
        if (!no->texto) {
            perror("strdup");
            exit(EXIT_FAILURE);
        }
    }
    if (tipo_no == N_TIPO && texto) no->tipo = tipo_de_nome(texto);
    else if (tipo_no == N_STRING) no->tipo = TIPO_STRING;
    no->filho[0] = a;
    no->filho[1] = b;
    no->filho[2] = c;
    return no;
}

No *no_num(int linha, double valor) {
    No *no = no_novo(linha, N_NUM, NULL, NULL, NULL, NULL);
    no->num = valor;
    /* O scanner entrega so o valor: inteiro se nao tem parte fracionaria. */
    no->tipo = (valor == (double)(long long)valor) ? TIPO_INT : TIPO_DOUBLE;
    return no;
}

No *no_char(int linha, int valor) {
    No *no = no_novo(linha, N_CHAR, NULL, NULL, NULL, NULL);
    no->tipo = TIPO_CHAR;
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

static void imprimir_char(int c) {
    switch (c) {
    case '\n': fputs("'\\n'", stdout); break;
    case '\t': fputs("'\\t'", stdout); break;
    case '\r': fputs("'\\r'", stdout); break;
    case '\0': fputs("'\\0'", stdout); break;
    case '\\': fputs("'\\\\'", stdout); break;
    case '\'': fputs("'\\''", stdout); break;
    default:
        if (c >= 32 && c < 127) printf("'%c'", c);
        else printf("'\\x%02x'", c & 0xff);
    }
}

void ast_imprimir(const No *no, int nivel) {
    for (; no; no = no->prox) {
        printf("%*s%s", nivel * 2, "", nomes[no->tipo_no]);
        if (no->tipo_no == N_NUM) {
            printf(" %g", no->num);
        } else if (no->tipo_no == N_CHAR) {
            putchar(' ');
            imprimir_char((int)no->num);
        } else if (no->texto) {
            printf(" %s", no->texto);
        }
        if (no->tipo != TIPO_DESCONHECIDO && no->tipo_no != N_TIPO)
            printf(" : %s", nomes_tipo[no->tipo]);
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

int tipo_numerico(Tipo tipo) {
    return tipo == TIPO_INT || tipo == TIPO_FLOAT || tipo == TIPO_DOUBLE || tipo == TIPO_CHAR;
}

int tipos_compativeis(Tipo destino, Tipo origem) {
    if (tipo_numerico(destino) && tipo_numerico(origem)) return 1;
    return destino == TIPO_STRING && origem == TIPO_STRING;
}

Tipo tipo_resultado_binop(const char *op, Tipo a, Tipo b) {
    if (a == TIPO_ERRO || b == TIPO_ERRO) return TIPO_ERRO;
    int igualdade = !strcmp(op, "==") || !strcmp(op, "!=");
    int comparacao = igualdade || !strcmp(op, "<") || !strcmp(op, "<=") ||
                     !strcmp(op, ">") || !strcmp(op, ">=");
    int logico = !strcmp(op, "&&") || !strcmp(op, "||");
    int real = a == TIPO_FLOAT || a == TIPO_DOUBLE || b == TIPO_FLOAT || b == TIPO_DOUBLE;
    int ok = (tipo_numerico(a) && tipo_numerico(b)) ||
             (igualdade && a == TIPO_STRING && b == TIPO_STRING);
    if (ok && !strcmp(op, "%") && real) ok = 0;   /* % so para inteiros */
    if (!ok) return TIPO_ERRO;
    if (comparacao || logico) return TIPO_INT;
    if (a == TIPO_DOUBLE || b == TIPO_DOUBLE) return TIPO_DOUBLE;
    if (a == TIPO_FLOAT || b == TIPO_FLOAT) return TIPO_FLOAT;
    return TIPO_INT;
}

Tipo tipo_resultado_unop(const char *op, Tipo a) {
    if (a == TIPO_ERRO || !tipo_numerico(a)) return TIPO_ERRO;
    if (!strcmp(op, "!") || a == TIPO_CHAR) return TIPO_INT;
    return a;
}
