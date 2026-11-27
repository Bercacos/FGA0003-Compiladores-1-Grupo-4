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

static double converter_numero(Tipo tipo, double numero);
static int avaliar_texto(const No *no, Ambiente *ambiente, char **resultado);

/* Decodifica um literal de string do fonte (com aspas e escapes). */
static char *decodificar_string(const char *literal) {
    size_t tamanho = strlen(literal);
    char *saida = malloc(tamanho + 1);
    if (saida == NULL) {
        perror("malloc");
        exit(EXIT_FAILURE);
    }
    size_t j = 0;
    for (size_t i = 1; i + 1 < tamanho; i++) {   /* pula as aspas */
        char c = literal[i];
        if (c == '\\' && i + 2 < tamanho) {
            i++;
            switch (literal[i]) {
                case 'n': c = '\n'; break;
                case 't': c = '\t'; break;
                case 'r': c = '\r'; break;
                case '0': c = '\0'; break;
                default:  c = literal[i]; break;
            }
        }
        saida[j++] = c;
    }
    saida[j] = '\0';
    return saida;
}

/* Variavel com valor, usada por ++ e --. */
static Variavel *variavel_com_valor(const No *id, Ambiente *ambiente) {
    Variavel *v = buscar_variavel(ambiente, id->texto);
    if (v == NULL || !v->inicializada) {
        fprintf(stderr, "Erro de execucao na linha %d: variavel '%s' sem valor\n",
                id->linha, id->texto);
        return NULL;
    }
    return v;
}

static int avaliar_expressao(const No *no, Ambiente *ambiente, double *resultado) {
    if (no == NULL) return 1;

    if (no->tipo_no == N_CHAR) {
        *resultado = no->num;
        return 0;
    }

    if (no->tipo_no == N_UNOP) {
        double operando;
        if (avaliar_expressao(no->filho[0], ambiente, &operando) != 0) return 1;
        if (strcmp(no->texto, "!") == 0) *resultado = operando == 0;
        else if (strcmp(no->texto, "-") == 0) *resultado = -operando;
        else *resultado = operando;
        return 0;
    }

    /* ++x / --x devolvem o valor novo; x++ / x-- devolvem o antigo. */
    if (no->tipo_no == N_PREINC || no->tipo_no == N_POSINC) {
        Variavel *v = variavel_com_valor(no->filho[0], ambiente);
        if (v == NULL) return 1;
        double antigo = v->valor.numero;
        double passo = strcmp(no->texto, "++") == 0 ? 1 : -1;
        v->valor.numero = converter_numero(v->valor.tipo, antigo + passo);
        *resultado = no->tipo_no == N_PREINC ? v->valor.numero : antigo;
        return 0;
    }

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

    if (no->tipo_no == N_BINOP &&
        (strcmp(no->texto, "&&") == 0 || strcmp(no->texto, "||") == 0)) {
        double esquerda, direita;
        if (avaliar_expressao(no->filho[0], ambiente, &esquerda) != 0) return 1;
        int e = esquerda != 0;
        if ((no->texto[0] == '&' && !e) || (no->texto[0] == '|' && e)) {
            *resultado = e;     /* curto-circuito: o lado direito nao e avaliado */
            return 0;
        }
        if (avaliar_expressao(no->filho[1], ambiente, &direita) != 0) return 1;
        *resultado = direita != 0;
        return 0;
    }

    /* == e != entre strings (a semantica so permite esses dois). */
    if (no->tipo_no == N_BINOP && no->filho[0]->tipo == TIPO_STRING) {
        char *a, *b;
        if (avaliar_texto(no->filho[0], ambiente, &a) != 0) return 1;
        if (avaliar_texto(no->filho[1], ambiente, &b) != 0) {
            free(a);
            return 1;
        }
        int iguais = strcmp(a, b) == 0;
        free(a);
        free(b);
        *resultado = strcmp(no->texto, "==") == 0 ? iguais : !iguais;
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
        else if (strcmp(no->texto, "%") == 0) {
            if ((long long)direita == 0) {
                fprintf(stderr, "Erro de execucao na linha %d: resto de divisao por zero\n",
                        no->linha);
                return 1;
            }
            *resultado = (long long)esquerda % (long long)direita;
        }
        else if (strcmp(no->texto, "<") == 0)
            *resultado = esquerda < direita;
        else if (strcmp(no->texto, "<=") == 0)
            *resultado = esquerda <= direita;
        else if (strcmp(no->texto, ">") == 0)
            *resultado = esquerda > direita;
        else if (strcmp(no->texto, ">=") == 0)
            *resultado = esquerda >= direita;
        else if (strcmp(no->texto, "==") == 0)
            *resultado = esquerda == direita;
        else if (strcmp(no->texto, "!=") == 0)
            *resultado = esquerda != direita;
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

/* Avalia uma expressao do tipo string (literal ou variavel). O texto devolvido
 * e uma copia que deve ser liberada por quem chamou. */
static int avaliar_texto(const No *no, Ambiente *ambiente, char **resultado) {
    if (no->tipo_no == N_STRING) {
        *resultado = decodificar_string(no->texto);
        return 0;
    }
    if (no->tipo_no == N_ID) {
        Variavel *v = buscar_variavel(ambiente, no->texto);
        if (v == NULL || !v->inicializada) {
            fprintf(stderr, "Erro de execucao na linha %d: variavel '%s' sem valor\n",
                    no->linha, no->texto);
            return 1;
        }
        *resultado = strdup(v->valor.texto);
        if (*resultado == NULL) {
            perror("strdup");
            exit(EXIT_FAILURE);
        }
        return 0;
    }
    fprintf(stderr, "Erro de execucao na linha %d: expressao de string invalida\n", no->linha);
    return 1;
}

static int avaliar_valor(const No *no, Ambiente *ambiente, Valor *resultado) {
    if (no->tipo == TIPO_STRING) {
        char *texto;
        if (avaliar_texto(no, ambiente, &texto) != 0) return 1;
        *resultado = (Valor){ .tipo = TIPO_STRING, .texto = texto };
        return 0;
    }

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

    if (!tipo_numerico(tipo) && tipo != TIPO_STRING) {
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

            if (tipo == TIPO_STRING) v->valor.texto = inicial.texto;
            else v->valor.numero = converter_numero(tipo, inicial.numero);
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

    if (!tipo_numerico(v->valor.tipo) && v->valor.tipo != TIPO_STRING) {
        fprintf(stderr, "Erro de execucao na linha %d: tipo ainda nao suportado\n",
                no->linha);
        return 1;
    }

    Valor novo;
    if (avaliar_valor(no->filho[0], ambiente, &novo) != 0) return 1;

    if (v->valor.tipo == TIPO_STRING) {
        free((char *)v->valor.texto);
        v->valor.texto = novo.texto;
        v->inicializada = 1;
        return 0;
    }

    v->valor.numero = converter_numero(v->valor.tipo, novo.numero);
    v->inicializada = 1;
    return 0;
}

static void liberar_ambiente(Ambiente *ambiente) {
    Variavel *atual = ambiente->variaveis;

    while (atual != NULL) {
        Variavel *proxima = atual->proxima;
        free((char *)atual->valor.texto);
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

        case N_EXPR_STMT: {
            /* Ex.: "i++;" - avalia pelo efeito colateral e descarta o valor. */
            Valor descartado;
            if (avaliar_valor(comando->filho[0], ambiente, &descartado) != 0) return 1;
            if (descartado.tipo == TIPO_STRING) free((char *)descartado.texto);
            return 0;
        }

        case N_FUNCAO:
            /* Funcoes ficaram fora do escopo: a definicao e verificada pela
             * semantica, mas nao ha chamada de funcao na linguagem. */
            return 0;

        case N_PRINT: {
            if (comando->filho[0] == NULL) return 1;

            int primeiro = 1;
            for (const No *arg = comando->filho[0]; arg != NULL; arg = arg->prox) {
                Valor valor;
                if (avaliar_valor(arg, ambiente, &valor) != 0) return 1;
                if (!primeiro) putchar(' ');
                if (valor.tipo == TIPO_STRING) {
                    fputs(valor.texto, stdout);
                    free((char *)valor.texto);
                } else if (valor.tipo == TIPO_INT) {
                    printf("%lld", (long long)valor.numero);
                } else if (valor.tipo == TIPO_CHAR) {
                    putchar((int)valor.numero);
                } else {
                    printf("%g", valor.numero);
                }
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