# Decisões técnicas

Registro das escolhas principais do Grupo 4 e suas justificativas.

## 1. Interpretador (não compilador)

Seguimos o [Guia — Projeto de um interpretador](https://github.com/sergioaafreitas/COMP1/blob/main/semana%2001/docs/Guia%20-%20Projeto%20de%20um%20interpretador.md) do professor Sergio Freitas: front-end com Flex/Bison e, depois, execução direta sobre uma AST — sem gerar binário nativo como produto final.

## 2. Linguagem-fonte: subconjunto de C

C foi escolhida por ser familiar ao curso e por ter material de apoio abundante nas práticas da disciplina. O escopo foi reduzido de propósito:

- tipos escalares simples (`int`, `float`, `double`, `char`, `string`)
- expressões, atribuições e blocos
- `if`/`else`, funções e `return`

Fora do escopo atual: ponteiros, estruturas, arrays, laços e biblioteca padrão.

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

Testes em shell (`tests/test_parser.sh` e `tests/teste_parser_extra.sh`) verificam apenas o código de saída do analisador:

- entrada válida → exit 0
- entrada inválida → exit ≠ 0

É uma suíte simples, alinhada à etapa atual (ainda sem semântica/execução), e fácil de rodar no WSL.

## 7. Tratamento de erros

- Léxico: mensagem própria + devolução do caractere inválido
- Sintático: `parse.error detailed` do Bison + `yyerror` com linha e lexema próximo

Ainda não há recuperação sofisticada (panic mode avançado); a prioridade foi diagnosticar a falha e abortar a análise.
