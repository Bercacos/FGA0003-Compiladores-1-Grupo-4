# Análise sintática

O parser está em `src/parser.y` e usa Bison. O analisador valida a sintaxe; ainda não constrói AST, verifica tipos ou executa instruções.

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

`print` é uma extensão deste subconjunto de C, assim como `string`. Não é uma chamada de `printf` da biblioteca padrão. Funções e `return`, já existentes, foram preservados.

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
int main(void) {
    int i = 0;
    while (i < 5 && !(i == 3)) {
        if (i != 1) print("valor", i);
        else print("pulado");
        i++;
    }
    return 0;
}
```

Este código é reconhecido sintaticamente; `print` e `while` ainda não são executados.

## Validação e limites

`make test` reúne as suítes principal, adicional e de escopo (`tests/test_scope.sh`). A nova suíte cobre aceitação e rejeição, integração com o léxico, aninhamento e entradas malformadas.

A execução desta atualização está pendente: o ambiente de edição bloqueou o WSL e o Bash do Windows. A existência dos scripts não comprova a conclusão da Issue 1 nem substitui sua execução.

Fora deste escopo: `for`, `do/while`, `switch`, ponteiros, arrays, structs, chamadas gerais de função e biblioteca padrão. Literais inteiros hexadecimais, sufixos inteiros e operadores bit a bit não foram incluídos nesta extensão. Análise semântica e interpretação são etapas posteriores.
