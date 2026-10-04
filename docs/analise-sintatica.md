# Análise sintática

A análise sintática está em `src/parser.y` e usa **Bison** com `%define parse.error detailed`.

## Objetivo atual

Validar se o fluxo de tokens forma um programa sintaticamente correto no subconjunto de C definido pelo grupo. Nesta etapa **não há AST nem execução**.

## Construções aceitas

- Programa como sequência de comandos (também aceita programa vazio)
- Declarações com tipos `int`, `float`, `double`, `char`, `string`
- Vários declaradores na mesma linha (`int a = 1, b = 2;`)
- Atribuições (`x = expr;`)
- Expressões aritméticas e relacionais com precedência e associatividade
- Parênteses, unários `+`/`-`, pré/pós `++`/`--`
- Blocos `{ ... }`
- `if` e `if/else` (incluindo aninhamento, com precedência `%prec THEN` / `KW_ELSE`)
- Definição de funções com parâmetros tipados, sem parâmetros ou `(void)`
- `return;` e `return expressao;`

## Precedência dos operadores

Do menor para o maior nível de precedência:

1. `==`, `!=`
2. `<`, `<=`, `>`, `>=`
3. `+`, `-`
4. `*`, `/`, `%`
5. unários `+` / `-`
6. resolução de ambiguidade do `else` (`THEN` / `KW_ELSE`)

## Esboço da gramática

```text
programa  → ε | programa comando
comando   → declaração ; | atribuição ; | expressão ; | bloco
          | if | return ; | return expressão ; | função
bloco     → { programa }
if        → if ( expressão ) comando
          | if ( expressão ) comando else comando
função    → tipo IDENT ( parâmetros ) bloco
          | void IDENT ( parâmetros ) bloco
```

## Mensagens de erro

```text
Erro sintatico na linha N, proximo a 'token': mensagem
```

O `main` do parser:

- lê um arquivo passado por argumento ou a entrada padrão
- chama `yyparse()`
- imprime `Analise sintatica concluida com sucesso.` quando o código é aceito

## O que ainda não faz parte desta etapa

- `while`, `for`, `switch`, ponteiros, arrays e structs
- Construção de AST nas ações semânticas
- Tabela de símbolos / verificação de tipos
- Chamada de função em expressão (só a **definição** está na gramática)
- Interpretação do programa

Esses itens entram nas sprints de semântica e interpretação, conforme o guia do professor.
