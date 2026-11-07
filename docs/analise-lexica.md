# Análise léxica

O scanner está em `src/analisador-lexico/scanner.l`, usa Flex e devolve os tokens declarados pelo Bison em `parser.tab.h`.

## Palavras reservadas

`if`, `else`, `while`, `print`, `return`, `int`, `float`, `double`, `char`, `string`, `void`. O token `for` continua reservado no léxico, mas a estrutura está fora do escopo do parser.

`var` na lista de requisitos é tratado como referência a variáveis: a linguagem usa declarações como `int x = 1;`, sem inferência de tipos por uma palavra-chave `var`.

## Identificadores e literais

| Classe | Formas reconhecidas | Token |
| --- | --- | --- |
| Identificador | Letras, dígitos e `_`, sem começar por dígito | `IDENT` |
| Número | Inteiros decimais e ponto flutuante, como `42`, `1.5`, `.5`, `1.`, `2e-3`, `1.5f` | `NUMBER` |
| String | Aspas duplas, com escapes e sem quebra de linha literal | `STRINGLIT` |
| Caractere | Um caractere ou escape entre aspas simples | `CHARLIT` |

O sinal é um operador separado. Strings e caracteres preservam o reconhecimento de escapes existente; sua interpretação cabe às etapas seguintes.

## Operadores e pontuação

- Aritméticos: `+`, `-`, `*`, `/`, `%`
- Relacionais e igualdade: `<`, `<=`, `>`, `>=`, `==`, `!=`
- Lógicos: `&&`, `||`, `!`
- Atribuição e incremento: `=`, `++`, `--`
- Delimitadores: `( ) { } [ ] ; ,` (colchetes não têm regra sintática)

As palavras reservadas são reconhecidas antes de identificadores; nomes como `print_total` continuam identificadores.

## Espaços, comentários e erros

Espaços, comentários `//` e `/* ... */` e diretivas iniciadas por `#` no começo da linha são ignorados. Diretivas não são expandidas: não há pré-processador C.

O estado exclusivo `COMENTARIO` permite detectar fim de arquivo antes de `*/`. Nesse caso o scanner emite uma mensagem de erro e devolve `INVALID`. Caracteres desconhecidos também devolvem `INVALID`, garantindo rejeição pelo parser. Strings e caracteres com quebra de linha literal são rejeitados.

A opção `yylineno` mantém a linha para os diagnósticos. O programa termina com status diferente de zero em caso de erro; ainda não há recuperação avançada nem modo de listagem de tokens.
