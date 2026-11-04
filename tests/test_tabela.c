/* Testes unitarios da tabela de simbolos (sem Flex/Bison). */
#include <stdio.h>
#include <string.h>
#include "../src/tabela.h"

static int falhas = 0;
static int total = 0;

#define CHECA(cond, nome) do { \
    total++; \
    if (cond) printf("OK  %s\n", nome); \
    else { printf("FALHOU  %s\n", nome); falhas++; } \
} while (0)

int main(void) {
    tabela_iniciar();

    CHECA(tabela_escopo_atual() == ESCOPO_GLOBAL, "comeca no escopo global");
    CHECA(tabela_inserir("x", CAT_VARIAVEL, TIPO_INT, ESCOPO_GLOBAL, 1) == TABELA_OK, "insere x global");
    CHECA(tabela_inserir("x", CAT_VARIAVEL, TIPO_FLOAT, ESCOPO_GLOBAL, 2) == TABELA_REDECLARADO, "rejeita redeclaracao no mesmo escopo");
    CHECA(tabela_buscar("x", ESCOPO_GLOBAL)->tipo == TIPO_INT, "redeclaracao nao altera o simbolo original");
    CHECA(tabela_buscar("x", ESCOPO_GLOBAL)->linha == 1, "guarda a linha da declaracao");
    CHECA(tabela_buscar("y", ESCOPO_GLOBAL) == NULL, "nome inexistente retorna NULL");

    int f = tabela_entrar_escopo("f");
    CHECA(f == 1 && tabela_escopo_atual() == 1, "entrar_escopo cria escopo 1");
    CHECA(tabela_buscar("x", f) != NULL && tabela_buscar("x", f)->escopo == ESCOPO_GLOBAL, "busca sobe para o escopo externo");
    CHECA(tabela_buscar_no_escopo("x", f) == NULL, "buscar_no_escopo nao sobe");
    CHECA(tabela_inserir("x", CAT_VARIAVEL, TIPO_FLOAT, f, 5) == TABELA_OK, "local pode ocultar o global");
    CHECA(tabela_buscar("x", f)->tipo == TIPO_FLOAT, "o mais interno vence");
    CHECA(tabela_buscar("x", ESCOPO_GLOBAL)->tipo == TIPO_INT, "global continua inalterado");

    int b = tabela_entrar_escopo(NULL);
    CHECA(b == 2 && tabela_buscar("x", b)->tipo == TIPO_FLOAT, "escopo aninhado enxerga o pai imediato");
    CHECA(tabela_sair_escopo() == 0 && tabela_escopo_atual() == f, "sair volta ao pai");
    CHECA(tabela_sair_escopo() == 0 && tabela_escopo_atual() == ESCOPO_GLOBAL, "sair volta ao global");
    CHECA(tabela_sair_escopo() == -1, "nao sai do escopo global");

    int irmao = tabela_entrar_escopo("g");
    CHECA(irmao == 3, "novo escopo recebe novo id");
    CHECA(tabela_inserir("x", CAT_PARAMETRO, TIPO_CHAR, irmao, 9) == TABELA_OK, "escopos irmaos sao independentes");
    CHECA(tabela_buscar("x", irmao)->tipo == TIPO_CHAR, "irmao ve o proprio x");
    tabela_sair_escopo();

    CHECA(tabela_inserir("z", CAT_VARIAVEL, TIPO_INT, 99, 1) == TABELA_ESCOPO_INVALIDO, "escopo invalido");
    CHECA(tabela_buscar("x", 99) == NULL, "busca em escopo invalido retorna NULL");

    tabela_imprimir();
    tabela_liberar();

    tabela_iniciar();
    CHECA(tabela_buscar("x", ESCOPO_GLOBAL) == NULL, "tabela vazia apos liberar e reiniciar");
    tabela_liberar();

    printf("\nTabela de simbolos: %d/%d testes passaram.\n", total - falhas, total);
    return falhas == 0 ? 0 : 1;
}
