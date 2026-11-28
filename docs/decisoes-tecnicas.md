# Decisões técnicas

Registro das escolhas principais do Grupo 4 e suas justificativas.

## 1. Interpretador (não compilador)

Seguimos o [Guia — Projeto de um interpretador](https://github.com/sergioaafreitas/COMP1/blob/main/semana%2001/docs/Guia%20-%20Projeto%20de%20um%20interpretador.md) do professor Sergio Freitas: front-end com Flex/Bison e, depois, execução direta sobre uma AST — sem gerar binário nativo como produto final.

## 2. Linguagem-fonte: subconjunto de C

C foi escolhida por ser familiar ao curso e por ter material de apoio abundante nas práticas da disciplina. O escopo foi reduzido de propósito:

- tipos escalares simples (`int`, `float`, `double`, `char`, `string`)
- expressões, atribuições e blocos
- `if`/`else`, `while` e `print`

Fora do escopo atual: declarações/definições e chamadas de funções, `return`, ponteiros, estruturas, arrays, `for`, `do/while`, `switch` e biblioteca padrão. O parser conserva regras antigas para definição e retorno, mas o interpretador não as executa e não há chamadas de função.

## 3. Ferramentas: Flex + Bison + C + Make

| Ferramenta | Motivo |
| --- | --- |
| Flex | Padrão da disciplina para análise léxica |
| Bison | Parser LALR(1) com integração natural ao Flex |
| C (`gcc`) | Linguagem de implementação dos exemplos do curso |
| Make | Um comando (`make`) gera lexer, parser e binário |

## 4. Pipeline incremental

Em vez de tentar AST + semântica + interpretação de uma vez, o grupo fechou primeiro o reconhecimento léxico-sintático. Isso permite:

- apresentar progresso claro nos pontos de controle
- manter testes de aceitação/rejeição desde cedo
- evoluir para AST sem reescrever o front-end

## 5. Documentação com MkDocs Material + GitHub Pages

A wiki do projeto vive em `docs/` e é publicada automaticamente na branch `gh-pages` pelo workflow `.github/workflows/docs.yml` a cada alteração em `docs/**` ou `mkdocs.yml`.

Motivos:

- o professor avalia documentação no repositório
- Material for MkDocs oferece navegação, busca e tema legível
- o site fica acessível em [bercacos.github.io/FGA0003-Compiladores-1-Grupo-4](https://bercacos.github.io/FGA0003-Compiladores-1-Grupo-4/)

## 6. Estratégia de testes

`make test` reúne testes de aceitação e rejeição de programas, verificações de tipos e escopos, testes unitários e de integração da tabela de símbolos, testes da estrutura impressa da AST e testes de saída e erros do interpretador.

Os testes automatizados podem ser complementados por variações manuais das entradas, usadas para observar mensagens de erro, hierarquia da árvore, símbolos registrados e resultados do modo `--run`.

## 7. Tratamento de erros

- Léxico: mensagem própria e devolução do token INVALID para entradas não reconhecidas ou malformadas
- Sintático: `parse.error detailed` do Bison + `yyerror` com linha e lexema próximo

Ainda não há recuperação sofisticada (panic mode avançado); a prioridade foi diagnosticar a falha e abortar a análise.

## 8. Execução opcional

O mesmo binário separa inspeção e execução. Sem `--run`, imprime AST e tabela de símbolos; com `--run`, percorre a árvore em `src/interpretador.c`. Ambientes encadeados guardam valores por bloco, e operadores lógicos usam curto-circuito. Esse recorte evita depender de uma função `main`: o programa é uma sequência de comandos no escopo global.
