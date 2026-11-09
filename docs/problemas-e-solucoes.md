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

**Problema.** Inicialmente, um comentário sem `*/` era rejeitado com uma mensagem sintática próxima de `*`, que não explicava a causa.

**Solução.** O analisador léxico passou a informar `comentario de bloco nao encerrado`. A entrada continua sendo rejeitada, agora com uma mensagem que identifica o problema.

## 5. Token `for` sem regra sintática

**Problema.** O scanner reconhece `for`, embora essa construção não tenha regra no parser.

**Solução.** `while` foi implementado; `for` permanece fora do escopo atual. Os testes esperam que um programa com `for` seja rejeitado.

## 6. Documentação acompanhando o código

**Problema.** A documentação foi criada em etapas e algumas páginas ainda descreviam a AST e a análise semântica como pendentes após sua implementação.

**Solução.** As páginas de estrutura, análise, tabela de símbolos e testes foram atualizadas para apresentar o estado atual do projeto.

## 7. Análise não é execução

**Problema.** A mensagem “Analise sintatica concluida com sucesso” pode ser confundida com a execução do programa recebido.

**Solução.** A documentação explica que o analisador constrói e imprime a AST e a tabela de símbolos, mas ainda não executa as instruções.