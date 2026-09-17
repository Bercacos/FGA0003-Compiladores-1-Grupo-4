# FGA0003-Compiladores-1-Grupo-4

Interpretador para uma linguagem semelhante a C, desenvolvido na disciplina de Compiladores 1.

## Analisador sintatico

Esta primeira versao reconhece declaracoes de variaveis dos tipos `int`, `float`, `double`, `char` e `string`, atribuicoes e expressoes com precedencia correta para `+`, `-`, `*`, `/`, `%`, comparacoes e parenteses. Tambem aceita varios declaradores e incremento/decremento.

Ponteiros, funcoes e estruturas de controle ainda nao fazem parte desta etapa. O parser verifica a sintaxe; tabela de simbolos, tipos e avaliacao pertencem a proxima etapa semantica.

## Uso no WSL

```bash
make
./build/analisador examples/variaveis.c
echo 'int x = y + z;' | ./build/analisador
make test
```

O projeto requer `flex`, `bison`, `gcc` e `make`.
