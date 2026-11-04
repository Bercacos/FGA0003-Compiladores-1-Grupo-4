#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabela.h"

/*
 * Implementacao: lista encadeada de simbolos (na ordem de insercao) +
 * vetor de escopos, onde cada escopo aponta para o escopo pai.
 * A busca sobe a cadeia de pais, do escopo mais interno ate o global.
 */

typedef struct {
    int pai;        /* id do escopo pai; -1 para o global */
    char *rotulo;   /* nome para exibicao: "global", nome da funcao, "bloco" */
} Escopo;

static Simbolo *inicio = NULL;
static Simbolo *fim = NULL;
static Escopo *escopos = NULL;
static int total_escopos = 0;
static int capacidade_escopos = 0;
static int escopo_atual = ESCOPO_GLOBAL;
static int iniciada = 0;

static char *copiar_texto(const char *texto) {
    size_t tamanho = strlen(texto) + 1;
    char *copia = malloc(tamanho);
    if (copia != NULL) memcpy(copia, texto, tamanho);
    return copia;
}

static int adicionar_escopo(int pai, const char *rotulo) {
    if (total_escopos == capacidade_escopos) {
        int nova = capacidade_escopos == 0 ? 8 : capacidade_escopos * 2;
        Escopo *novo = realloc(escopos, (size_t)nova * sizeof(Escopo));
        if (novo == NULL) return -1;
        escopos = novo;
        capacidade_escopos = nova;
    }
    char *copia = copiar_texto(rotulo);
    if (copia == NULL) return -1;
    escopos[total_escopos].pai = pai;
    escopos[total_escopos].rotulo = copia;
    return total_escopos++;
}

static int escopo_valido(int escopo) {
    return escopo >= 0 && escopo < total_escopos;
}

void tabela_iniciar(void) {
    if (iniciada) tabela_liberar();
    iniciada = 1;
    escopo_atual = ESCOPO_GLOBAL;
    adicionar_escopo(-1, "global");
}

static void garantir_iniciada(void) {
    if (!iniciada) tabela_iniciar();
}

int tabela_entrar_escopo(const char *rotulo) {
    garantir_iniciada();
    int id = adicionar_escopo(escopo_atual, rotulo != NULL ? rotulo : "bloco");
    if (id < 0) return -1;
    escopo_atual = id;
    return id;
}

int tabela_sair_escopo(void) {
    garantir_iniciada();
    if (escopo_atual == ESCOPO_GLOBAL) return -1;
    escopo_atual = escopos[escopo_atual].pai;
    return 0;
}

int tabela_escopo_atual(void) {
    garantir_iniciada();
    return escopo_atual;
}

Simbolo *tabela_buscar_no_escopo(const char *nome, int escopo) {
    garantir_iniciada();
    for (Simbolo *s = inicio; s != NULL; s = s->proximo) {
        if (s->escopo == escopo && strcmp(s->nome, nome) == 0) return s;
    }
    return NULL;
}

Simbolo *tabela_buscar(const char *nome, int escopo) {
    garantir_iniciada();
    if (!escopo_valido(escopo)) return NULL;
    for (int e = escopo; e != -1; e = escopos[e].pai) {
        Simbolo *s = tabela_buscar_no_escopo(nome, e);
        if (s != NULL) return s;
    }
    return NULL;
}

TabelaStatus tabela_inserir(const char *nome, Categoria categoria, Tipo tipo,
                            int escopo, int linha) {
    garantir_iniciada();
    if (!escopo_valido(escopo)) return TABELA_ESCOPO_INVALIDO;
    if (tabela_buscar_no_escopo(nome, escopo) != NULL) return TABELA_REDECLARADO;

    Simbolo *novo = malloc(sizeof(Simbolo));
    if (novo == NULL) return TABELA_SEM_MEMORIA;
    novo->nome = copiar_texto(nome);
    if (novo->nome == NULL) {
        free(novo);
        return TABELA_SEM_MEMORIA;
    }
    novo->categoria = categoria;
    novo->tipo = tipo;
    novo->escopo = escopo;
    novo->linha = linha;
    novo->proximo = NULL;

    if (fim == NULL) inicio = novo;
    else fim->proximo = novo;
    fim = novo;
    return TABELA_OK;
}

const char *tabela_categoria_para_texto(Categoria categoria) {
    switch (categoria) {
        case CAT_VARIAVEL:  return "variavel";
        case CAT_FUNCAO:    return "funcao";
        case CAT_PARAMETRO: return "parametro";
    }
    return "?";
}

const char *tabela_status_para_texto(TabelaStatus status) {
    switch (status) {
        case TABELA_OK:              return "ok";
        case TABELA_REDECLARADO:     return "redeclaracao no mesmo escopo";
        case TABELA_ESCOPO_INVALIDO: return "escopo invalido";
        case TABELA_SEM_MEMORIA:     return "memoria insuficiente";
    }
    return "?";
}

void tabela_imprimir(void) {
    garantir_iniciada();
    printf("\nTabela de simbolos:\n");
    printf("%-16s %-10s %-8s %-16s %s\n", "Nome", "Categoria", "Tipo", "Escopo", "Linha");
    for (Simbolo *s = inicio; s != NULL; s = s->proximo) {
        char escopo[64];
        if (s->escopo == ESCOPO_GLOBAL) snprintf(escopo, sizeof escopo, "global");
        else snprintf(escopo, sizeof escopo, "%s#%d", escopos[s->escopo].rotulo, s->escopo);
        printf("%-16s %-10s %-8s %-16s %d\n", s->nome,
               tabela_categoria_para_texto(s->categoria),
               tipo_para_texto(s->tipo), escopo, s->linha);
    }
}

void tabela_liberar(void) {
    Simbolo *s = inicio;
    while (s != NULL) {
        Simbolo *proximo = s->proximo;
        free(s->nome);
        free(s);
        s = proximo;
    }
    inicio = fim = NULL;
    for (int i = 0; i < total_escopos; i++) free(escopos[i].rotulo);
    free(escopos);
    escopos = NULL;
    total_escopos = capacidade_escopos = 0;
    escopo_atual = ESCOPO_GLOBAL;
    iniciada = 0;
}
