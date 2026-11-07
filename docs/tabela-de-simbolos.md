# Tabela de símbolos

Implementada em `src/tabela.c` / `src/tabela.h` (tipos em `src/tipos.h`), seguindo o material da Semana 6 do professor (AST e tabela de símbolos).

## O que cada símbolo guarda

| Campo | Descrição |
| --- | --- |
| Nome | identificador declarado |
| Categoria | `variavel`, `funcao` ou `parametro` |
| Tipo | `int`, `float`, `double`, `char`, `string` ou `void` (enum `Tipo`) |
| Escopo | `global`, ou `<rótulo>#<id>` (ex.: `soma#1`, `bloco#2`) |
| Linha | linha da declaração |

## Escopos

- O escopo `0` é o global. Cada função abre um escopo (parâmetros e corpo compartilham o mesmo) e cada bloco `{ ... }` abre um escopo filho.
- A busca (`tabela_buscar`) começa no escopo informado e sobe para os escopos externos; o mais interno vence.
- Redeclaração é avaliada **somente no escopo atual**: `int x; { int x; }` é válido, `int x; int x;` não é.
- Os símbolos permanecem na tabela depois que o escopo termina (para impressão e para a análise semântica), mas deixam de ser visíveis de fora dele.

## API

| Função | Uso |
| --- | --- |
| `tabela_iniciar()` | cria a tabela com o escopo global |
| `tabela_entrar_escopo(rotulo)` / `tabela_sair_escopo()` | abre / fecha escopo |
| `tabela_inserir(nome, categoria, tipo, escopo, linha)` | devolve `TABELA_OK` ou o motivo da falha (`TABELA_REDECLARADO`, ...) |
| `tabela_buscar(nome, escopo)` | busca do escopo interno para o externo |
| `tabela_buscar_no_escopo(nome, escopo)` | busca apenas no escopo informado |
| `tabela_imprimir()` | imprime a tabela |
| `tabela_liberar()` | libera toda a memória |

## Integração com o parser

As declarações alimentam a tabela nas reduções do Bison (`declarador`, `parametro`, `cabecalho_funcao`) e `bloco` abre/fecha escopo. A linha vem de `@N.first_line`, preenchido pelo `YY_USER_ACTION` do `scanner.l`. Redeclaração gera `Erro semantico na linha N: ...` e o programa termina com código ≠ 0.

Uso de identificador **não declarado** ainda não é rejeitado: `tabela_buscar` já está pronta para a análise semântica da próxima etapa.

## Exemplo

```bash
printf 'int a = 10;\nint b = 20;\nint soma = a + b * 2;\n' | ./build/analisador
```

```text
Analise sintatica concluida com sucesso.

Tabela de simbolos:
Nome             Categoria  Tipo     Escopo           Linha
a                variavel   int      global           1
b                variavel   int      global           2
soma             variavel   int      global           3
```

## Testes

`make test` roda também `tests/test_tabela.c` (unitário, sem Flex/Bison) e `tests/test_tabela.sh` (integração com o parser).
