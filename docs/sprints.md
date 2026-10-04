# Planejamento das sprints

Planejamento baseado no guia do professor ([Sugestão de Sprints para interpretador](https://github.com/sergioaafreitas/COMP1/blob/main/semana%2001/docs/Guia%20-%20Projeto%20de%20um%20interpretador.md)) e no histórico real do repositório do Grupo 4.

## Visão geral

| Sprint | Foco | Status |
| --- | --- | --- |
| 1 | Equipe, ambiente, escopo da linguagem, estrutura do repo | Concluída |
| 2 | Análise léxica + início do parser + P1 | Concluída |
| 3 | Parser completo (variáveis, expressões, `if`, funções) + testes | Concluída (AST ainda pendente) |
| 4 | AST + semântica inicial + preparação P2 | Em andamento / próxima |
| 5 | Interpretação da AST + recursos extras | Pendente |
| 6 | Documentação final, ajustes e entrevista | Em andamento (docs) |

## Sprint 1 — Organização e ambiente

**Objetivos**

- Formar a equipe e criar o repositório GitHub
- Configurar Flex, Bison, GCC e Make no WSL/Linux
- Definir o interpretador de um subconjunto de C
- Criar a estrutura inicial (`src/`, `tests/`, `examples/`, `docs/`)

**Entregas realizadas**

- Repositório `FGA0003-Compiladores-1-Grupo-4`
- Commit inicial de estrutura (`docs/`, `src/`, `tests/`, `examples/`)
- Ambiente validado com exemplos da disciplina

## Sprint 2 — Léxico e primeiras regras sintáticas (P1)

**Objetivos**

- Completar o `scanner.l` (keywords, literais, operadores, comentários)
- Integrar Flex com Bison
- Apresentar o Ponto de Controle P1

**Entregas realizadas**

- Analisador léxico inicial e expansões (`analisador-lexico`)
- Ajustes para uso com o parser
- Parser inicial de declarações/expressões de variáveis

## Sprint 3 — Parser utilizável e testes

**Objetivos**

- Ampliar a gramática (blocos, `if`/`else`, funções, `return`)
- Automatizar testes de aceitação/rejeição
- Publicar documentação no GitHub Pages

**Entregas realizadas**

- `parser.y` com variáveis, expressões, `if`, funções e `return`
- `Makefile` e exemplo `examples/variaveis.c`
- Setup MkDocs + workflow de deploy
- Documentação de testes (`docs/testes.md`) e suíte extra (30 casos)

**Pendência em relação ao guia do professor**

- A Sprint 3 do guia também pede AST; no Grupo 4 a AST ficou para a Sprint 4, para estabilizar antes o reconhecimento sintático.

## Sprint 4 — AST e semântica (próxima)

**Objetivos**

- Criar nós de AST nas ações do Bison
- Iniciar tabela de símbolos e checagens básicas (variável declarada, tipos simples)
- Melhorar mensagens de erro
- Preparar o Ponto de Controle P2

**Entregas esperadas**

- Estruturas `ast.h` / `ast.c` (ou equivalente)
- Tabela de símbolos inicial
- Testes semânticos além dos testes só sintáticos

## Sprint 5 — Interpretação

**Objetivos**

- Percorrer a AST e executar atribuições, expressões e `if`
- Evoluir semântica (escopo, funções, se houver tempo)
- Ampliar exemplos e testes de execução

## Sprint 6 — Entrega e entrevista

**Objetivos**

- Fechar documentação (estrutura, decisões, sprints, problemas/soluções)
- Revisar README e exemplos de uso
- Preparar a entrevista final com o professor

## Papéis nas sprints

Distribuição observada até aqui (ajustável pela equipe):

| Integrante | Contribuições principais |
| --- | --- |
| Bernardo | Bootstrap do repo e parser de variáveis |
| Lucas | Léxico, expansão sintática, MkDocs/Pages |
| Ian | Testes automatizados e página de testes |
| Kaio | Documentação completa do projeto nesta wiki |
