# FGA0003-Compiladores-1-Grupo-4

Interpretador para um subconjunto da linguagem C, desenvolvido na disciplina de Compiladores 1 (UnB/FGA).

## Documentação

A documentação completa está no GitHub Pages:

**https://bercacos.github.io/FGA0003-Compiladores-1-Grupo-4/**

Fonte em `docs/` (MkDocs Material). Para ver localmente:

```bash
pip install -r requirements-docs.txt
mkdocs serve
```

## Estado atual

O front-end léxico-sintático reconhece declarações (`int`, `float`, `double`, `char`, `string`), atribuições, expressões com precedência, blocos, `if`/`else`, definições de funções e `return`.

Ainda **não** há AST, análise semântica nem execução do programa: o binário só aceita ou rejeita a entrada.

## Uso no WSL/Linux

```bash
make
./build/analisador examples/variaveis.c
echo 'int x = y + z;' | ./build/analisador
make test
bash tests/teste_parser_extra.sh ./build/analisador
```

Requisitos: `flex`, `bison`, `gcc` e `make`.

## Testes

Os testes dos analisadores léxico e sintático estão descritos em [docs/testes.md](docs/testes.md).

## Material do professor

Passo a passo e requisitos de documentação:

- [Trabalho de Compiladores](https://github.com/sergioaafreitas/COMP1/blob/main/semana%2001/docs/Trabalho%20de%20Compiladores.md)
- [Guia — Projeto de um interpretador](https://github.com/sergioaafreitas/COMP1/blob/main/semana%2001/docs/Guia%20-%20Projeto%20de%20um%20interpretador.md)
