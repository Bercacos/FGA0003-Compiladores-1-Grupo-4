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

O front-end léxico-sintático reconhece declarações (`int`, `float`, `double`, `char`, `string`), atribuições, expressões com precedência, blocos, `if`/`else`, `while`, `print` e operadores lógicos.

A AST, a tabela de símbolos, as verificações iniciais de tipos e escopos e o interpretador estão implementados. Sem opções, o binário imprime a AST e a tabela; com `--run`, executa declarações e atribuições, expressões, blocos, `if`/`else`, `while` e `print`.

Declarações/definições e chamadas de funções não fazem parte do escopo funcional. A gramática ainda aceita definições de função e `return` por compatibilidade com uma etapa anterior, mas o interpretador ignora esses nós e não existe sintaxe para chamadas.

## Uso no WSL/Linux

```bash
make
./build/analisador examples/variaveis.c
./build/analisador --run examples/interpretador.c
printf '%s\n' 'int y = 1; int z = 2; int x = y + z;' | ./build/analisador
make test
bash tests/teste_parser_extra.sh ./build/analisador
```

Requisitos: `flex`, `bison`, `gcc` e `make`.

## Testes

`make test` executa as suítes do parser, escopo, tabela de símbolos, análise semântica, AST e interpretação. A suíte de interpretação inclui 40 casos. Veja a cobertura e os comandos em [docs/testes.md](docs/testes.md).

## Material do professor

Passo a passo e requisitos de documentação:

- [Trabalho de Compiladores](https://github.com/sergioaafreitas/COMP1/blob/main/semana%2001/docs/Trabalho%20de%20Compiladores.md)
- [Guia — Projeto de um interpretador](https://github.com/sergioaafreitas/COMP1/blob/main/semana%2001/docs/Guia%20-%20Projeto%20de%20um%20interpretador.md)
