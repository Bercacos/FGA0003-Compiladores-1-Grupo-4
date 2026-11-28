# Testes do analisador e do interpretador

Os testes automatizados estão em `tests/` e são executados com `make test`. As instruções de uso estão em [Como usar](uso.md).

## Objetivo

Verificar o reconhecimento léxico, a aceitação ou rejeição das construções da linguagem, as verificações de tipos e escopos, a estrutura da AST, os dados da tabela de símbolos e o comportamento do modo `--run`.

## Testes realizados

Na análise léxica, foram verificados identificadores, palavras reservadas, números, strings, caracteres, operadores, comentários e caracteres não reconhecidos. Também foram observadas as mensagens de erro e a indicação da linha em que o erro ocorre.

Na análise sintática, foram testadas declarações de variáveis, atribuições, expressões aritméticas e comparações, uso de parênteses, múltiplos declaradores, incremento e decremento e blocos delimitados por chaves. Para cada grupo de construções, foram usadas entradas válidas e inválidas.

## Resultados

Na rodada de 27/11/2026, `make test` compilou o projeto no WSL e concluiu todas as suítes com sucesso. A nova suíte de execução do interpretador passou em 40 de 40 casos. A execução do exemplo `examples/interpretador.c` também produziu as saídas esperadas.

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

Os testes da AST conferem a ordem e a hierarquia dos nós na saída do analisador. A suíte do interpretador usa programas curtos para verificar comportamentos específicos de execução.

## Atualização após as novas regras sintáticas

Em uma etapa anterior, a suíte adicional passou a aceitar `if`/`else` e também regras sintáticas de definição de função e `return`. Esses testes históricos continuam no repositório, mas funções não fazem parte do escopo funcional atual.

Os casos verificam `if` simples, `if-else`, `if` aninhado e rejeições relacionadas. Casos de função e `return` apenas registram o comportamento legado do parser, não uma capacidade do interpretador.

| Entrada | Resultado esperado | Saída observada |
| --- | --- | --- |
| `if (1) { int x = 2; }` | Aceitar | `Analise sintatica concluida com sucesso.` |
| `if () { int x = 1; }` | Rejeitar | Erro sintático: `unexpected RPAREN` |

## Extensão do escopo até `while`

A suíte `tests/test_scope.sh` adiciona 47 casos de aceitação e rejeição para `while`, `print`, operadores lógicos, comandos vazios e integração com tipos, literais, blocos e `if/else`. Inclui decimais com expoentes, comentários sem fechamento e strings com quebra de linha literal.

## Testes da AST e da tabela de símbolos

A suíte `tests/test_ast.sh`, executada por `make test`, verifica trechos da árvore impressa. Os testes conferem a hierarquia e a ordem dos nós, além da aceitação dos programas usados como entrada.

| Entrada | Estrutura verificada na AST |
| --- | --- |
| `int a = 10; int b = 20; int soma = a + b * 2;` | A multiplicação aparece como filha da soma, respeitando a precedência. |
| `int x = 1; if (x) { x = x + 2; } else { x = x - 1; }` | O `If` contém a condição e dois blocos, na ordem de `if` e `else`. |
| `int soma(int a, int b) { return a + b; }` | Teste histórico: a AST ainda representa a regra legada, sem execução ou chamada. |
| `int x = 0; while (x < 3) { x = x + 1; }` | O `While` contém a condição e o bloco do corpo. |

A tabela de símbolos é testada isoladamente em `tests/test_tabela.c` e junto ao analisador em `tests/test_tabela.sh`. Esses testes verificam inserção e busca de símbolos, nomes, categorias, tipos, escopos, linhas, ocultação de variáveis e rejeição de redeclarações.

## Testes de execução

`tests/test_interpretador.sh` é executado por `make test`. Os 40 casos incluem 34 programas com saída esperada, quatro erros de execução e duas verificações do modo de uso.

- Os casos de sucesso comparam a saída padrão e exigem código de saída zero. Cobrem aritmética, conversões entre tipos numéricos, caracteres, strings, comparações, curto-circuito, incremento e decremento, `if`/`else`, `while`, escopo de blocos e `print` com vários argumentos.
- Os casos de erro exigem código de saída diferente de zero e conferem o diagnóstico de divisão por zero, resto de divisão por zero e leitura ou incremento de variável sem valor.
- Os dois casos restantes verificam o modo padrão de análise e se um erro semântico impede a execução mesmo quando há um `print` antes do erro.

Para rodar apenas essa suíte:

```bash
make
bash tests/test_interpretador.sh ./build/analisador
```

## Verificação manual da execução

```bash
./build/analisador --run examples/interpretador.c
```

Entre as saídas esperadas estão `divisao inteira: 3`, `divisao real: 3.5`, `5! = 120`, `x dentro do bloco: 99` e `x fora do bloco: 1`.
