#ifndef TABELA_H
#define TABELA_H

#include "tipos.h"

/*
 * FGA0003 - Compiladores 1 - Grupo 4
 * Tabela de simbolos com escopos aninhados.
 *
 * Cada simbolo guarda: nome, categoria, tipo, escopo e linha de declaracao.
 * Escopos sao identificados por inteiros: 0 e o escopo global; cada chamada a
 * tabela_entrar_escopo() cria um novo escopo filho do escopo atual.
 * Os simbolos continuam na tabela depois que o escopo termina (para impressao
 * e para a analise semantica posterior), mas deixam de ser visiveis a partir
 * dos escopos externos.
 */

#define ESCOPO_GLOBAL 0

typedef enum {
    CAT_VARIAVEL,
    CAT_FUNCAO,
    CAT_PARAMETRO
} Categoria;

typedef enum {
    TABELA_OK = 0,
    TABELA_REDECLARADO,      /* ja existe simbolo com esse nome no mesmo escopo */
    TABELA_ESCOPO_INVALIDO,  /* escopo inexistente */
    TABELA_SEM_MEMORIA       /* malloc falhou */
} TabelaStatus;

typedef struct simbolo {
    char *nome;
    Categoria categoria;
    Tipo tipo;
    int escopo;
    int linha;
    struct simbolo *proximo;
} Simbolo;

/* Cria a tabela com o escopo global. Pode ser chamada de novo apos tabela_liberar(). */
void tabela_iniciar(void);

/* Escopos. Retornam o id do escopo criado / -1 em erro. */
int tabela_entrar_escopo(const char *rotulo);   /* rotulo pode ser NULL ("bloco") */
int tabela_sair_escopo(void);                   /* 0 em sucesso, -1 se ja esta no global */
int tabela_escopo_atual(void);

/* Insere o simbolo no escopo indicado. Nao insere se houver redeclaracao no mesmo escopo. */
TabelaStatus tabela_inserir(const char *nome, Categoria categoria, Tipo tipo,
                            int escopo, int linha);

/* Busca do escopo informado para os escopos externos (o mais interno vence). */
Simbolo *tabela_buscar(const char *nome, int escopo);

/* Busca apenas no escopo informado (usada para detectar redeclaracao). */
Simbolo *tabela_buscar_no_escopo(const char *nome, int escopo);

const char *tabela_categoria_para_texto(Categoria categoria);
const char *tabela_status_para_texto(TabelaStatus status);

void tabela_imprimir(void);
void tabela_liberar(void);

#endif
