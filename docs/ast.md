# Árvore sintática abstrata (AST)

A AST representa a estrutura dos programas reconhecidos pelo analisador. Ela é construída durante a análise sintática, pelas ações de `src/parser.y`, com os nós definidos em `src/ast.h` e implementados em `src/ast.c`.

## Estrutura

Cada nó registra sua categoria e a linha de origem. Dependendo da categoria, também guarda um nome, operador ou valor, filhos e o tipo associado à expressão. Comandos, declaradores, parâmetros e argumentos são encadeados na ordem em que aparecem no programa.

A árvore representa declarações, atribuições, blocos, `if`/`else`, `while`, `print`, funções, `return` e expressões. Por exemplo, um nó `If` possui a condição, o comando do `if` e, quando presente, o comando do `else`.

## Exemplo

Para o programa:

```c
int a = 10;
int b = 20;
int soma = a + b * 2;
```

A parte da AST correspondente à expressão de `soma` é:

```text
BinOp + : int  (linha 3)
  Id a : int  (linha 3)
  BinOp * : int  (linha 3)
    Id b : int  (linha 3)
    Num 2 : int  (linha 3)
```

A multiplicação aparece como filha da soma, preservando a precedência dos operadores. Quando há parênteses, seu efeito aparece na organização dos nós; eles não precisam de um nó próprio.

## Testes

`make test` executa `tests/test_ast.sh`, que confere a estrutura da árvore em quatro programas. Os casos e resultados estão descritos em [Testes](testes.md).