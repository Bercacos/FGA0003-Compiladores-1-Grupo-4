# Análise sintática

O parser está em `src/parser.y` e usa Bison. Ele valida a sintaxe, constrói a AST e realiza verificações de tipos e escopos com a tabela de símbolos. A AST pode ser executada pelo interpretador com `--run`.

## Comparação com o escopo até `while`

| Requisito | Situação anterior | Alteração |
| --- | --- | --- |
| Tipos básicos | `int`, `float`, `double`, `char`, `string` | Mantidos |
| Variáveis (`var` na lista de requisitos) | Declarações, inicializações, atribuições e múltiplos declaradores | Mantidos; declarações usam tipos explícitos, sem palavra-chave `var` |
| Literais | Inteiros decimais, decimais com dígitos antes/depois do ponto, caracteres e strings | Acrescentados `.5`, `1.`, expoentes e sufixos de ponto flutuante |
| Operadores | Aritméticos, relacionais, igualdade, `=`, `++`, `--` | Acrescentados `&&`, `||`, `!` |
| Blocos | Blocos vazios e aninhados | Mantidos |
| `if`/`else` | Com e sem chaves; aninhados | Mantidos; agora também aceitam comando vazio `;` |
| `while` | Token no léxico, sem produção sintática | Implementado com condição, bloco ou comando único, incluindo `;` |
| `print` | Ausente | Implementado `print(expressao, ...);`, com pelo menos um argumento |

`print` é uma extensão deste subconjunto de C, assim como `string`. Não é uma chamada de `printf` da biblioteca padrão.

## Gramática das novas instruções

```text
comando         : ... | ; | comando_while | comando_print ;
comando_while   : while ( expressao ) comando
comando_print   : print ( argumentos_print )
argumentos_print: expressao | argumentos_print , expressao
```

O `else` se associa ao `if` mais próximo que ainda não tem `else`, inclusive quando há um `while` entre eles. `while` aceita aninhamento, corpo vazio e instruções sem chaves.

## Precedência dos operadores

Da menor para a maior: `||`; `&&`; `==` e `!=`; `<`, `<=`, `>`, `>=`; `+` e `-`; `*`, `/`, `%`; unários `+`, `-`, `!`. Parênteses permitem agrupamento explícito. Incremento e decremento continuam restritos a identificadores.

## Exemplo integrado

```c
int i = 0;
while (i < 5 && !(i == 3)) {
    if (i != 1) print("valor", i);
    else print("pulado");
    i++;
}
```

Este código é reconhecido e pode ser executado com `./build/analisador --run`.

## Validação e limites

A suíte de escopo inclui casos válidos e inválidos para `while`, `print`, operadores lógicos e integração com as demais construções. Ela é executada por `make test`, junto com as outras [suítes do projeto](testes.md).

Fora do escopo atual estão declarações/definições e chamadas de funções, `return`, `for`, `do/while`, `switch`, ponteiros, arrays, structs e biblioteca padrão. O parser ainda contém produções legadas para definições de função e `return`, mas elas não representam suporte funcional: não há chamadas e o interpretador ignora definições.
