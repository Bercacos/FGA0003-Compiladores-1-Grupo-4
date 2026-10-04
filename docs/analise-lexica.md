# Análise léxica

A análise léxica está em `src/analisador-lexico/scanner.l` e usa **Flex**. O scanner devolve tokens definidos em conjunto com o Bison (`parser.tab.h`).

## O que o scanner reconhece

### Palavras reservadas

`if`, `while`, `for`, `else`, `return`, `int`, `float`, `char`, `string`, `double`, `void`

> Observação: `while` e `for` já são tokens léxicos, mas ainda **não possuem regras sintáticas** no parser.

### Identificadores e literais

| Classe | Padrão / forma | Token |
| --- | --- | --- |
| Identificador | `[a-zA-Z_][a-zA-Z0-9_]*` | `IDENT` |
| Número | `[0-9]+(\.[0-9]+)?` | `NUMBER` |
| String | `"..."` com escapes | `STRINGLIT` |
| Caractere | `'x'` com escape simples | `CHARLIT` |

### Operadores e pontuação

- Aritméticos: `+`, `-`, `*`, `/`, `%`
- Relacionais/igualdade: `<`, `<=`, `>`, `>=`, `==`, `!=`
- Atribuição e incremento: `=`, `++`, `--`
- Delimitadores: `( ) { } [ ] ; ,`

### Itens ignorados

- Espaços em branco (`espaço`, tab, CR, LF)
- Comentários de linha (`// ...`)
- Comentários de bloco (`/* ... */`)
- Diretivas de pré-processador no início da linha (`#include`, `#define`, ...)

## Tratamento de erros

Caracteres não reconhecidos geram mensagem no `stderr` com o número da linha:

```text
Erro lexico na linha N: caractere nao reconhecido '...'
```

O caractere é devolvido ao parser, que em geral também falha em seguida.

## Opções Flex usadas

```c
%option yylineno noyywrap noinput nounput
```

- `yylineno` — rastreia a linha para mensagens de erro
- `noyywrap` — um único arquivo/fluxo de entrada
- `noinput` / `nounput` — evitam avisos de funções não usadas

## Limitações conhecidas desta etapa

- Comentário de bloco sem fechamento não gera mensagem léxica específica; a falha aparece depois no parser
- Não há modo de impressão da lista de tokens (útil para depuração)
- `while`/`for` reconhecidos no léxico ainda não são aceitos na gramática
