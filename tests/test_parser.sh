#!/usr/bin/env bash
set -u
analisador="${1:-./build/analisador}"
falhas=0
testa_valido() {
    local codigo="$1"
    if ! printf '%s\n' "$codigo" | "$analisador" >/dev/null 2>&1; then
        printf 'FALHOU (deveria aceitar): %s\n' "$codigo"
        falhas=$((falhas + 1))
    fi
}
testa_invalido() {
    local codigo="$1"
    if printf '%s\n' "$codigo" | "$analisador" >/dev/null 2>&1; then
        printf 'FALHOU (deveria rejeitar): %s\n' "$codigo"
        falhas=$((falhas + 1))
    fi
}
testa_valido 'int x = y + z;'
testa_valido 'int x = 2 + 3 * 4; float y = (x - 1) / 2;'
testa_valido 'int a = 1, b = a + 2; b = b % 2;'
testa_valido '++x; y--;'
testa_invalido 'int x = ;'
testa_invalido 'int x = 1'
testa_invalido 'x = (2 + 3;'
if (( falhas > 0 )); then
    printf '%d teste(s) falharam.\n' "$falhas"
    exit 1
fi
printf 'Todos os testes passaram.\n'
