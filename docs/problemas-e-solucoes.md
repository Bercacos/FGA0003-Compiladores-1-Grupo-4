# Problemas encontrados e soluções adotadas

Registro das dificuldades do Grupo 4 até a etapa léxico-sintática.

## 1. Integração Flex ↔ Bison

**Problema.** O scanner precisa conhecer os códigos de token gerados pelo Bison (`parser.tab.h`). Compilar na ordem errada quebra o build.

**Solução.** O `Makefile` gera primeiro o parser (`bison -d`) e só depois o lexer (`flex`), incluindo `build/` no `-I` do `gcc`.

## 2. Ambiguidade do `if/else`

**Problema.** Gramáticas com `if` opcionalmente seguido de `else` geram conflito shift/reduce clássico (“dangling else”).

**Solução.** Uso de precedências no Bison:

```yacc
%precedence THEN
%precedence KW_ELSE
```

e a produção do `if` sem `else` marcada com `%prec THEN`, fazendo o `else` associar ao `if` mais interno.

## 3. Precedência e associatividade das expressões

**Problema.** Expressões como `2 + 3 * 4` ou comparações encadeadas precisam de ordem estável.

**Solução.** Declarações `%left` no `parser.y` para igualdade, relacionais, soma e produto, além de `%precedence` para unários.

## 4. Comentário de bloco sem fechamento

**Problema.** A entrada `int x = 8 /* comentario sem fim;` é rejeitada, mas a mensagem aponta erro sintático próximo de `*`, não “comentário não terminado”.

**Solução parcial.** Mantivemos a rejeição (comportamento correto) e documentamos o caso em [Testes](testes.md) como ponto de melhoria. Melhoria futura: regra léxica/`<<EOF>>` que reporte comentário aberto.

## 5. Tokens léxicos ainda sem regra sintática

**Problema.** `while` e `for` já existem no scanner, mas o parser ainda não os aceita — o que pode confundir quem testa essas construções.

**Solução.** Deixar os tokens preparados no léxico (evita retrabalho) e documentar claramente que laços entram em sprint futura. Testes atuais não esperam aceitação de `while`/`for`.

## 6. Escopo da documentação vs. código

**Problema.** O GitHub Pages foi publicado cedo, mas a página inicial ficou com a seção **Estado atual** vazia e sem as seções exigidas pelo enunciado (estrutura, decisões, sprints, problemas/soluções).

**Solução.** Reorganizar a wiki MkDocs com páginas dedicadas a cada requisito do professor e preencher o estado real do interpretador (léxico/sintático prontos; AST/semântica/execução pendentes).

## 7. Limite da etapa atual

**Problema.** É fácil interpretar “análise concluída com sucesso” como se o programa tivesse sido executado.

**Solução.** Deixar explícito no README e na documentação que o analisador **apenas valida** a entrada. Execução só existirá após AST + interpretador.
