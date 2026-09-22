#!/usr/bin/env bash
# Testes adicionais para o analisador sintatico do Grupo 4.
# Uso: bash teste_parser_extra.sh ./build/analisador

set -u

analisador="${1:-./build/analisador}"
falhas=0
total=0

testar() {
    local esperado="$1"
    local nome="$2"
    local codigo="$3"
    local saida
    local status

    total=$((total + 1))
    saida=$(printf '%s\n' "$codigo" | "$analisador" 2>&1)
    status=$?

    if { [[ "$esperado" == aceita && "$status" -eq 0 ]] ||
         [[ "$esperado" == rejeita && "$status" -ne 0 ]]; }; then
        printf 'OK  %s\n' "$nome"
    else
        printf 'FALHOU  %s (esperado: %s; codigo de saida: %s)\n' "$nome" "$esperado" "$status"
        printf 'Entrada: %s\nSaida: %s\n' "$codigo" "$saida"
        falhas=$((falhas + 1))
    fi
}

testar aceita 'programa vazio' ''
testar aceita 'todos os tipos declarados' 'int a; float b; double c; char d; string e;'
testar aceita 'multiplos declaradores e atribuicao' 'int a = 1, b = a + 2; b = b * 3;'
testar aceita 'operadores e parenteses' 'float x = (1 + 2) * 3 / 4 % 2;'
testar aceita 'comparacoes' 'int x = 1 < 2 == 3 >= 4;'
testar aceita 'incremento e decremento' '++x; --x; x++; x--;'
testar aceita 'blocos aninhados' '{ int x = 1; { x = x + 1; } }'
testar aceita 'comentario de linha' $'// comentario\nint x = 1;'
testar aceita 'comentario de bloco multilinha' $'/* comentario\nem duas linhas */\nint x = 1;'
testar aceita 'strings e caracteres' 'string s = "ola"; char c = '\''a'\'';'

testar rejeita 'falta ponto e virgula' 'int x = 1'
testar rejeita 'inicializador ausente' 'int x = ;'
testar rejeita 'atribuicao incompleta' 'x = ;'
testar rejeita 'parentese aberto' 'x = (1 + 2;'
testar rejeita 'bloco aberto' '{ int x = 1;'
testar rejeita 'caractere desconhecido' 'int x = 1 @ 2;'
testar rejeita 'palavra reservada como identificador' 'int if = 1;'
testar rejeita 'numero malformado' 'float x = 1.2.3;'
testar rejeita 'string nao fechada' 'string s = "ola;'
testar rejeita 'if ainda nao implementado' 'if (1) { int x = 2; }'

printf '\nResultado: %s/%s testes passaram.\n' "$((total - falhas))" "$total"
if ((falhas > 0)); then
    exit 1
fi
