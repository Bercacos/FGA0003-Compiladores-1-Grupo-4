# Estrutura do projeto

Organização atual do repositório:

```text
FGA0003-Compiladores-1-Grupo-4/
├── .github/workflows/docs.yml   # CI que publica o MkDocs em gh-pages
├── docs/                        # Fonte da documentação (esta wiki)
├── examples/                    # Programas de exemplo
│   └── variaveis.c
├── src/
│   ├── analisador-lexico/
│   │   └── scanner.l            # Regras léxicas (Flex)
│   └── parser.y                 # Gramática e parser (Bison)
├── tests/
│   ├── test_parser.sh           # Suíte principal
│   └── teste_parser_extra.sh    # Suíte ampliada
├── Makefile
├── mkdocs.yml
├── requirements-docs.txt
└── README.md
```

## Papel de cada pasta

| Caminho | Função |
| --- | --- |
| `src/analisador-lexico/scanner.l` | Converte o texto-fonte em tokens para o parser |
| `src/parser.y` | Valida a gramática e reporta erros sintáticos |
| `build/` | Artefatos gerados (`lex.yy.c`, `parser.tab.*`, binário) — não versionado |
| `tests/` | Scripts bash de aceitação/rejeição |
| `examples/` | Entradas manuais para demonstração |
| `docs/` + `mkdocs.yml` | Documentação publicada no GitHub Pages |

## Fluxo de compilação

1. `bison` gera `build/parser.tab.c` e `build/parser.tab.h` a partir de `parser.y`
2. `flex` gera `build/lex.yy.c` a partir de `scanner.l` (usa o header do Bison)
3. `gcc` liga os dois fontes gerados no executável `build/analisador`

## Fluxo de execução atual

```text
código-fonte (.c)
      │
      ▼
  scanner.l  ──► tokens
      │
      ▼
  parser.y   ──► aceita / rejeita
```

Nas próximas etapas, o parser deverá construir uma AST; em seguida entram a análise semântica e o interpretador.
