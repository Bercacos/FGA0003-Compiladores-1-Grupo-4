# FGA0003 - Compiladores 1 - Grupo 4

Interpretador para um subconjunto da linguagem C, desenvolvido na disciplina de Compiladores 1 (Engenharia de Software — UnB/FGA).

## Sobre o projeto

O projeto implementa, em etapas, um **interpretador** para um subconjunto de C, seguindo as fases clássicas de construção de compiladores/interpretadores:

1. **Análise léxica** — reconhecimento de tokens com `flex`
2. **Análise sintática** — verificação da gramática com `bison`
3. **Análise semântica** — tabela de símbolos, tipos e verificações *(próxima etapa)*
4. **Interpretação / execução** — avaliação da AST *(próxima etapa)*

A documentação abaixo segue os requisitos do professor ([Trabalho de Compiladores](https://github.com/sergioaafreitas/COMP1/blob/main/semana%2001/docs/Trabalho%20de%20Compiladores.md) e [Guia — Projeto de um interpretador](https://github.com/sergioaafreitas/COMP1/blob/main/semana%2001/docs/Guia%20-%20Projeto%20de%20um%20interpretador.md)): estrutura do projeto, decisões técnicas, planejamento das sprints, problemas encontrados e soluções adotadas.

## Estado atual

| Etapa | Status | Observação |
| --- | --- | --- |
| Ambiente e repositório | Concluído | `Makefile`, Flex/Bison e GitHub Pages com MkDocs |
| Análise léxica | Implementada e testada | Tokens, literais, operadores, comentários e erros léxicos |
| Análise sintática | Implementada e testada | Declarações, expressões, blocos, `if`/`else`, `while`, `print`, funções e `return` |
| AST | Implementada e testada | Representa as construções reconhecidas e imprime a árvore |
| Análise semântica | Verificações iniciais implementadas e testadas | Tabela de símbolos, escopos, declarações e compatibilidade básica de tipos |
| Interpretação | Pendente | As instruções analisadas ainda não são executadas |

Nesta versão, `build/analisador` analisa o código-fonte e imprime a AST e a tabela de símbolos. Ele ainda não executa o programa.

## Equipe

| Integrante | Papel principal observado no repositório |
| --- | --- |
| Bernardo Broetto Brun (`Bercacos`) | Estrutura inicial do projeto e analisador sintático de variáveis |
| Lucas Fujimoto Tokunaga (`Lucasft16`) | Analisador léxico, expansão do parser (`if`, funções) e setup do MkDocs/GitHub Pages |
| Ian Pedersoli (`ianpedersoli`) | Documentação e suíte de testes dos analisadores |
| Kaio Acacio (`kaioamoury`) | Documentação do projeto (esta wiki) |

## Navegação rápida

- [Como usar](uso.md) — compilar, executar e testar
- [Estrutura do projeto](estrutura.md)
- [Análise léxica](analise-lexica.md)
- [Análise sintática](analise-sintatica.md)
- [AST](ast.md)
- [Tabela de símbolos](tabela-de-simbolos.md)
- [Decisões técnicas](decisoes-tecnicas.md)
- [Planejamento das sprints](sprints.md)
- [Problemas e soluções](problemas-e-solucoes.md)
- [Testes](testes.md)

## Site e repositório

- Repositório: [Bercacos/FGA0003-Compiladores-1-Grupo-4](https://github.com/Bercacos/FGA0003-Compiladores-1-Grupo-4)
- Documentação publicada: [GitHub Pages](https://bercacos.github.io/FGA0003-Compiladores-1-Grupo-4/)
- Material da disciplina: [sergioaafreitas/COMP1](https://github.com/sergioaafreitas/COMP1)
