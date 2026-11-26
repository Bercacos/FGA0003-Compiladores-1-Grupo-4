#include <stdio.h>
#include <string.h>
#include "interpretador.h"
#include <stdlib.h>

typedef struct {
    Tipo tipo;
    double numero;
    const char *texto;
} Valor;

typedef struct Variavel {
    const char *nome;
    Valor valor;
    int inicializada;
    struct Variavel *proxima;
} Variavel;

typedef struct Ambiente {
    Variavel *variaveis;
    struct Ambiente *pai;
} Ambiente;

static Variavel *buscar_variavel(Ambiente *ambiente, const char *nome) {
    for (Ambiente *atual = ambiente; atual != NULL; atual = atual->pai) {
        for (Variavel *v = atual->variaveis; v != NULL; v = v->proxima) {
            if (strcmp(v->nome, nome) == 0) return v;
        }
    }
    return NULL;
}

static int avaliar_expressao(const No *no, Ambiente *ambiente, double *resultado) {
    if (no == NULL) return 1;

    if (no->tipo_no == N_NUM) {
        *resultado = no->num;
        return 0;
    }

    if (no->tipo_no == N_ID) {
    Variavel *v = buscar_variavel(ambiente, no->texto);

    if (v == NULL || !v->inicializada) {
        fprintf(stderr, "Erro de execucao na linha %d: variavel '%s' sem valor\n",
                no->linha, no->texto);
        return 1;
    }

    if (!tipo_numerico(v->valor.tipo)) {
        fprintf(stderr, "Erro de execucao na linha %d: tipo ainda nao suportado\n",
                no->linha);
        return 1;
    }

    *resultado = v->valor.numero;
    return 0;
}

    if (no->tipo_no == N_BINOP) {
        double esquerda, direita;

        if (avaliar_expressao(no->filho[0], ambiente, &esquerda) != 0) return 1;
        if (avaliar_expressao(no->filho[1], ambiente, &direita) != 0) return 1;

        if (strcmp(no->texto, "+") == 0)
            *resultado = esquerda + direita;
        else if (strcmp(no->texto, "-") == 0)
            *resultado = esquerda - direita;
        else if (strcmp(no->texto, "*") == 0)
            *resultado = esquerda * direita;
        else if (strcmp(no->texto, "/") == 0) {
            if (direita == 0) {
                fprintf(stderr, "Erro de execucao na linha %d: divisao por zero\n",
                    no->linha);
                return 1;
    }

            *resultado = esquerda / direita;
            if (no->tipo == TIPO_INT)
            *resultado = (long long)*resultado;
}
        else {
            fprintf(stderr, "Erro de execucao na linha %d: operador ainda nao suportado\n",
                    no->linha);
            return 1;
        }
        return 0;
    }

    fprintf(stderr, "Erro de execucao na linha %d: expressao ainda nao suportada\n",
            no->linha);
    return 1;
}

static int avaliar_valor(const No *no, Ambiente *ambiente, Valor *resultado) {
    double numero;
   if (avaliar_expressao(no, ambiente, &numero) != 0) return 1;

    *resultado = (Valor){ .tipo = no->tipo, .numero = numero };
    return 0;
}

static double converter_numero(Tipo tipo, double numero) {
    if (tipo == TIPO_INT) return (int)numero;
    if (tipo == TIPO_FLOAT) return (float)numero;
    if (tipo == TIPO_CHAR) return (unsigned char)(int)numero;
    return numero;
}

static int executar_declaracao(const No *no, Ambiente *ambiente) {
    Tipo tipo = no->filho[0]->tipo;

    if (!tipo_numerico(tipo)) {
        fprintf(stderr, "Erro de execucao na linha %d: tipo ainda nao suportado\n",
                no->linha);
        return 1;
    }

    for (const No *declarador = no->filho[1];
         declarador != NULL;
         declarador = declarador->prox) {
        Variavel *v = calloc(1, sizeof(*v));
        if (v == NULL) {
            perror("calloc");
            return 1;
        }

        v->nome = declarador->texto;
        v->valor.tipo = tipo;
        v->proxima = ambiente->variaveis;
        ambiente->variaveis = v;

        if (declarador->filho[0] != NULL) {
            Valor inicial;
            if (avaliar_valor(declarador->filho[0], ambiente, &inicial) != 0)
                return 1;

            v->valor.numero = converter_numero(tipo, inicial.numero);
            v->inicializada = 1;
        }
    }

    return 0;
}

static int executar_atribuicao(const No *no, Ambiente *ambiente) {
    Variavel *v = buscar_variavel(ambiente, no->texto);
    if (v == NULL) {
        fprintf(stderr, "Erro de execucao na linha %d: variavel '%s' nao encontrada\n",
                no->linha, no->texto);
        return 1;
    }

    if (!tipo_numerico(v->valor.tipo)) {
        fprintf(stderr, "Erro de execucao na linha %d: tipo ainda nao suportado\n",
                no->linha);
        return 1;
    }

    Valor novo;
    if (avaliar_valor(no->filho[0], ambiente, &novo) != 0) return 1;

    v->valor.numero = converter_numero(v->valor.tipo, novo.numero);
    v->inicializada = 1;
    return 0;
}

static void liberar_ambiente(Ambiente *ambiente) {
    Variavel *atual = ambiente->variaveis;

    while (atual != NULL) {
        Variavel *proxima = atual->proxima;
        free(atual);
        atual = proxima;
    }

    ambiente->variaveis = NULL;
}

static int executar_comando(const No *comando, Ambiente *ambiente);

static int executar_lista(const No *primeiro, Ambiente *ambiente) {
    for (const No *no = primeiro; no != NULL; no = no->prox) {
        if (executar_comando(no, ambiente) != 0) return 1;
    }
    return 0;
}

static int executar_comando(const No *comando, Ambiente *ambiente) {
    if (comando == NULL) return 0;

    switch (comando->tipo_no) {
        case N_DECL:
            return executar_declaracao(comando, ambiente);

        case N_ATRIB:
            return executar_atribuicao(comando, ambiente);

        case N_PRINT: {
            if (comando->filho[0] == NULL) return 1;

            int primeiro = 1;
            for (const No *arg = comando->filho[0]; arg != NULL; arg = arg->prox) {
                Valor valor;
                if (avaliar_valor(arg, ambiente, &valor) != 0) return 1;
                if (!primeiro) putchar(' ');
                printf("%g", valor.numero);
                primeiro = 0;
            }
            putchar('\n');
            return 0;
        }

        case N_BLOCO: {
            Ambiente local = { .pai = ambiente };
            int status = executar_lista(comando->filho[0], &local);
            liberar_ambiente(&local);
            return status;
        }

        case N_IF: {
            Valor condicao;
            if (avaliar_valor(comando->filho[0], ambiente, &condicao) != 0)
                return 1;

            const No *ramo = condicao.numero != 0
                ? comando->filho[1] : comando->filho[2];
            return executar_comando(ramo, ambiente);
        }

        case N_WHILE:
            for (;;) {
                Valor condicao;
                if (avaliar_valor(comando->filho[0], ambiente, &condicao) != 0)
                    return 1;
                if (condicao.numero == 0) return 0;
                if (executar_comando(comando->filho[1], ambiente) != 0)
                    return 1;
            }

        default:
            fprintf(stderr,
                    "Erro de execucao na linha %d: comando ainda nao suportado\n",
                    comando->linha);
            return 1;
    }
}

int interpretar(const No *raiz) {
    if (raiz == NULL || raiz->tipo_no != N_PROGRAMA) {
        fprintf(stderr, "Erro de execucao: programa invalido\n");
        return 1;
    }

    Ambiente global = {0};
    int status = executar_lista(raiz->filho[0], &global);
    liberar_ambiente(&global);
    return status;
}