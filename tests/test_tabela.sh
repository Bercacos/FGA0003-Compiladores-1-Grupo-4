#!/usr/bin/env bash
# Integracao parser + tabela de simbolos: confere conteudo da tabela e erros de redeclaracao.
set -u
analisador="${1:-./build/analisador}"
falhas=0
total=0
if [[ ! -x "$analisador" ]]; then
    printf 'Analisador nao encontrado ou nao executavel: %s\n' "$analisador" >&2
    exit 1
fi

# tabela_contem "codigo" "regex" -> a saida deve ter uma linha da tabela casando com a regex
contem() {
    local nome="$1" codigo="$2" regex="$3" saida
    total=$((total + 1))
    saida=$(printf '%s\n' "$codigo" | "$analisador" 2>&1)
    if grep -Eq "$regex" <<<"$saida"; then printf 'OK  %s\n' "$nome"
    else printf 'FALHOU  %s\n%s\n' "$nome" "$saida"; falhas=$((falhas + 1)); fi
}
# status "codigo" aceita|rejeita
status() {
    local nome="$1" codigo="$2" esperado="$3" rc
    total=$((total + 1))
    printf '%s\n' "$codigo" | "$analisador" >/dev/null 2>&1; rc=$?
    if { [[ $esperado == aceita && $rc -eq 0 ]] || [[ $esperado == rejeita && $rc -ne 0 ]]; }; then printf 'OK  %s\n' "$nome"
    else printf 'FALHOU  %s (status %s)\n' "$nome" "$rc"; falhas=$((falhas + 1)); fi
}

contem 'variavel global com tipo e linha' $'int a = 10;\nint b = 20;' '^b +variavel +int +global +2$'
contem 'tipo float' 'float f = 1.5;' '^f +variavel +float +global +1$'
contem 'declaradores multiplos' 'int a = 1, b = 2;' '^b +variavel +int +global +1$'
contem 'funcao no escopo global' $'void ola(void) { }' '^ola +funcao +void +global +1$'
contem 'parametro no escopo da funcao' 'int soma(int a, float b) { return a; }' '^b +parametro +float +soma#1 +1$'
contem 'variavel local da funcao' 'int f(void) { int r = 1; return r; }' '^r +variavel +int +f#1 +1$'
contem 'variavel de bloco' 'int x; { int x; }' '^x +variavel +int +bloco#1 +1$'
status 'mesmo nome em blocos irmaos' 'if (1) { int x = 2; } else { int x = 3; }' aceita
status 'local oculta global' 'int x; { int x; }' aceita
status 'redeclaracao no escopo global' $'int a;\nint a;' rejeita
status 'redeclaracao no mesmo bloco' '{ int a; int a; }' rejeita
status 'redeclaracao na mesma lista' 'int a, a;' rejeita
status 'parametro repetido' 'int f(int p, int p) { }' rejeita
status 'local redeclara parametro' 'int f(int p) { int p; }' rejeita
status 'funcao redeclarada' $'int f(void) { }\nint f(void) { }' rejeita
status 'mesmo nome em funcoes diferentes' $'int f(int p) { }\nint g(int p) { }' aceita

printf '\nTabela de simbolos (integracao): %d/%d testes passaram.\n' "$((total - falhas))" "$total"
((falhas == 0))
