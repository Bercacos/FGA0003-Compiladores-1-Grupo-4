# Estrutura do projeto

Organização dos principais arquivos do repositório:

```text
FGA0003-Compiladores-1-Grupo-4/
├── docs/                         # Documentação do projeto
├── examples/                     # Programas de exemplo
├── src/
│   ├── analisador-lexico/
│   │   └── scanner.l             # Regras léxicas (Flex)
│   ├── parser.y                  # Gramática e ações (Bison)
│   ├── ast.c / ast.h             # Estrutura e impressão da AST
│   ├── tabela.c / tabela.h       # Tabela de símbolos
│   └── tipos.h                   # Tipos usados pelo projeto
├── tests/
│   ├── test_parser.sh
│   ├── teste_parser_extra.sh
│   ├── test_scope.sh
│   ├── test_semantica.sh
│   ├── test_tabela.c / test_tabela.sh
│   └── test_ast.sh
├── Makefile                      # Compilação e testes
└── mkdocs.yml                    # Navegação da documentação
```

A pasta `build/` contém os arquivos gerados pelo Bison e pelo Flex e o executável `analisador`. Ela é criada durante a compilação e não é versionada.

## Fluxo de compilação

1. O Bison gera `build/parser.tab.c` e `build/parser.tab.h` a partir de `src/parser.y`.
2. O Flex gera `build/lex.yy.c` a partir de `src/analisador-lexico/scanner.l`.
3. O GCC compila os arquivos gerados junto com `src/ast.c` e `src/tabela.c`, produzindo `build/analisador`.

## Fluxo de análise

```text
Código-fonte
    ↓
Scanner (tokens)
    ↓
Parser (gramática, AST, tabela de símbolos e verificações)
    ↓
AST e tabela impressas; erros informados quando encontrados
```

O analisador ainda não executa as instruções do programa recebido. O comando `make test` executa as suítes de testes do projeto.