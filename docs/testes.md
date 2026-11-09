# Testes do analisador, da AST e da tabela de símbolos

Os testes automatizados estão em `tests/` e são executados com `make test`. As instruções de uso estão em [Como usar](uso.md).

## Objetivo

Verificar o reconhecimento léxico, a aceitação ou rejeição das construções da linguagem, as verificações de tipos e escopos, a estrutura da AST e os dados da tabela de símbolos. Testes manuais complementam as suítes com variações das entradas.

## Testes realizados

Na análise léxica, foram verificados identificadores, palavras reservadas, números, strings, caracteres, operadores, comentários e caracteres não reconhecidos. Também foram observadas as mensagens de erro e a indicação da linha em que o erro ocorre.

Na análise sintática, foram testadas declarações de variáveis, atribuições, expressões aritméticas e comparações, uso de parênteses, múltiplos declaradores, incremento e decremento e blocos delimitados por chaves. Para cada grupo de construções, foram usadas entradas válidas e inválidas.

## Resultados

O projeto compilou sem erros e o comando `make test` terminou sem falhas no WSL. Passaram as suítes do parser, escopo, tabela de símbolos, análise semântica e AST. Os testes manuais complementaram essas suítes com variações de programas válidos e inválidos, permitindo conferir a árvore impressa e os símbolos registrados.

### Exemplos de entradas e saídas

| Entrada | Resultado esperado | Saída observada |
| --- | --- | --- |
| `int _nome2 = 7;` | Aceitar | `Analise sintatica concluida com sucesso.` |
| `int nome$ = 7;` | Rejeitar | Erro léxico no `$`, seguido de erro sintático |
| `float x = 12.5;` | Aceitar | `Analise sintatica concluida com sucesso.` |
| `float x = 12.5.3;` | Rejeitar | Erro léxico no segundo `.`, seguido de erro sintático |
| `int x = 8; // comentario` | Aceitar | `Analise sintatica concluida com sucesso.` |
| `int x = 8 /* comentario */ / 2;` | Aceitar | `Analise sintatica concluida com sucesso.` |
| `int x = (2 + 3 * 4;` | Rejeitar | Erro sintático: `unexpected PONTOVIR` |
| `{ int x = 1; x++;` | Rejeitar | Erro sintático: `unexpected end of file` |
| `int x = 1; }` | Rejeitar | Erro sintático: `unexpected RCHAVE` |
| `int x = 8 /* comentario sem fim;` | Rejeitar | Erro léxico: `comentario de bloco nao encerrado`; erro sintático: `unexpected INVALID` |

## Limites dos testes

Os testes automatizados e manuais verificam o reconhecimento léxico, a sintaxe, a estrutura da AST impressa e a tabela de símbolos. Na tabela, foram conferidos nomes, categorias, tipos, escopos e linhas, além da busca de identificadores, ocultação de variáveis e rejeição de redeclarações.

Os testes da AST conferem a ordem e a hierarquia dos nós na saída do analisador. O projeto ainda não executa as instruções analisadas; portanto, os testes não verificam resultados da execução do interpretador.

## Atualização após as novas regras sintáticas

Após a inclusão de `if`/`else`, definições de funções e `return`, a suíte adicional foi atualizada. O teste que antes esperava a rejeição de `if` passou a esperar sua aceitação, e foram acrescentados dez casos. Na versão atual, a suíte principal passou (7/7) e a adicional passou (30/30).

Os novos casos verificam `if` simples, `if-else`, `if` aninhado, funções com parâmetros tipados, sem parâmetros e com `(void)`, e `return`. Também verificam a rejeição de `if` sem condição, `else` isolado, parâmetro sem tipo, vírgula final nos parâmetros e `return` sem ponto e vírgula.

| Entrada | Resultado esperado | Saída observada |
| --- | --- | --- |
| `if (1) { int x = 2; }` | Aceitar | `Analise sintatica concluida com sucesso.` |
| `if () { int x = 1; }` | Rejeitar | Erro sintático: `unexpected RPAREN` |
| `int soma(int a, int b) { return a + b; }` | Aceitar | `Analise sintatica concluida com sucesso.` |
| `int soma(int a,) { return a; }` | Rejeitar | Erro sintático: `unexpected RPAREN` |

## Extensão do escopo até `while`

A suíte `tests/test_scope.sh` adiciona 47 casos de aceitação e rejeição para `while`, `print`, operadores lógicos, comandos vazios e integração com tipos, literais, blocos e `if/else`. Inclui decimais com expoentes, comentários sem fechamento e strings com quebra de linha literal.

## Testes da AST e da tabela de símbolos

A suíte `tests/test_ast.sh`, executada por `make test`, verifica trechos da árvore impressa. Os testes conferem a hierarquia e a ordem dos nós, além da aceitação dos programas usados como entrada.

| Entrada | Estrutura verificada na AST |
| --- | --- |
| `int a = 10; int b = 20; int soma = a + b * 2;` | A multiplicação aparece como filha da soma, respeitando a precedência. |
| `int x = 1; if (x) { x = x + 2; } else { x = x - 1; }` | O `If` contém a condição e dois blocos, na ordem de `if` e `else`. |
| `int soma(int a, int b) { return a + b; }` | A função contém o tipo, os parâmetros e o `Return` com a soma. |
| `int x = 0; while (x < 3) { x = x + 1; }` | O `While` contém a condição e o bloco do corpo. |

A tabela de símbolos é testada isoladamente em `tests/test_tabela.c` e junto ao analisador em `tests/test_tabela.sh`. Esses testes verificam inserção e busca de símbolos, nomes, categorias, tipos, escopos, linhas, ocultação de variáveis e rejeição de redeclarações. Todas essas suítes passaram no WSL.