# FGA0003 - Compiladores 1 - Grupo 4

Interpretador para uma linguagem semelhante a C, desenvolvido na disciplina de Compiladores 1.

## Sobre o projeto

Este projeto implementa, em etapas, um compilador/interpretador para uma linguagem
simplificada semelhante a C. O desenvolvimento esta organizado nas fases classicas
de construcao de compiladores:

- **Analise lexica** - reconhecimento de tokens (`flex`)
- **Analise sintatica** - verificacao da gramatica (`bison`)
- **Analise semantica** - tabela de simbolos, tipos e verificacoes
- **Geracao/execucao** - avaliacao ou geracao de codigo

## Estado atual

A versao atual reconhece declaracoes de variaveis dos tipos `int`, `float`, `double`,
`char` e `string`, atribuicoes e expressoes com precedencia correta para `+`, `-`,
`*`, `/`, `%`, comparacoes e parenteses. Tambem aceita varios declaradores e
incremento/decremento.

Ponteiros, funcoes e estruturas de controle ainda nao fazem parte desta etapa. O
parser verifica a sintaxe; tabela de simbolos, tipos e avaliacao pertencem a
proxima etapa semantica.

Veja [Como usar](uso.md) para instrucoes de build e execucao.
