#!/usr/bin/env bash
# Cobertura do escopo ate while; nao depende de execucao/semantica.
set -u
analisador="${1:-./build/analisador}"
falhas=0
total=0
if [[ ! -x "$analisador" ]]; then
    printf 'Analisador nao encontrado ou nao executavel: %s\n' "$analisador" >&2
    exit 1
fi
testar() {
    local esperado="$1" nome="$2" codigo="$3" saida status
    total=$((total + 1))
    saida=$(printf '%s\n' "$codigo" | "$analisador" 2>&1)
    status=$?
    if { [[ "$esperado" == aceita && "$status" -eq 0 ]] ||
         [[ "$esperado" == rejeita && "$status" -ne 0 ]]; }; then
        printf 'OK  %s\n' "$nome"
    else
        printf 'FALHOU  %s (esperado: %s; status: %s)\n%s\n' "$nome" "$esperado" "$status" "$saida"
        falhas=$((falhas + 1))
    fi
}

testar aceita 'tipos e literais' 'int i = 42; float f = 2.5; double d = 3.0; char c = '\''a'\''; string s = "ola";'
testar aceita 'literais decimais e expoentes' 'float a = .5f; double b = 1.; double c = 2e-3; double d = 1.5E+2;'
testar aceita 'logicos em expressoes' 'int x = !a || b && c; int y = !!x;'
testar aceita 'todos os operadores binarios' 'int x = (a + b - c * d / e % f) < g <= h > i >= j == k != l && m || n;'
testar aceita 'while com bloco' 'int x = 0; while (x < 10) { x = x + 1; }'
testar aceita 'while sem chaves' 'while (x > 0) x--;'
testar aceita 'while com corpo vazio' 'while (0);'
testar aceita 'while com bloco vazio' 'while (0) {}'
testar aceita 'while com condicao composta' 'while (x < 10 && !(x == 5 || x == 6)) ++x;'
testar aceita 'while aninhado' 'while (x) { while (y) y--; x--; }'
testar aceita 'if dentro de while' 'while (x) if (x > 2) x--; else x = 0;'
testar aceita 'while dentro de if' 'if (x) while (y) y--; else x++;'
testar aceita 'else associado ao if interno atraves de while' 'if (a) while (b) if (c) x++; else x--;'
testar aceita 'comandos vazios' '; if (x); else;'
testar aceita 'print de texto' 'print("ola");'
testar aceita 'print de variavel e expressao' 'print(x); print(2 + 3 * 4);'
testar aceita 'print com varios argumentos' 'print("valor", x, '\''a'\'', !x);'
testar aceita 'print em if e else' 'if (x) print(x); else print("zero");'
testar aceita 'print em while' 'while (x) { print(x); x--; }'
testar aceita 'print preserva identificadores com prefixo' 'int print_total = 1; print(print_total);'
testar aceita 'programa integrado' 'int main(void) { int i = 0; while (i < 3) { if (i != 1 && !0) print("i", i); else print("pulado"); i++; } return 0; }'
testar aceita 'comentarios entre tokens' 'while /* condicao */ (x) { print(/* valor */ x); --x; }'
testar aceita 'comentario fechado apos programa' 'print(1); /* fim */'

testar rejeita 'while sem condicao' 'while () {}'
testar rejeita 'while sem parenteses' 'while x < 2 { x++; }'
testar rejeita 'while sem fechar parentese' 'while (x < 2 { x++; }'
testar rejeita 'while sem corpo' 'while (x)'
testar rejeita 'while sem fechar bloco' 'while (x) { x++;'
testar rejeita 'while com atribuicao incompleta' 'while (x) x = ;'
testar rejeita 'print sem argumento' 'print();'
testar rejeita 'print sem parenteses' 'print "ola";'
testar rejeita 'print sem ponto e virgula' 'print(x)'
testar rejeita 'print sem fechar parentese' 'print(x;'
testar rejeita 'print com virgula final' 'print(x,);'
testar rejeita 'print com argumento ausente' 'print(,x);'
testar rejeita 'print como identificador reservado' 'int print = 1;'
testar rejeita 'and incompleto' 'if (x &&) {}'
testar rejeita 'or incompleto' 'while (|| x) {}'
testar rejeita 'not incompleto' 'int x = !;'
testar rejeita 'ampersand isolado' 'while (x & y) {}'
testar rejeita 'barra vertical isolada' 'int x = a | b;'
testar rejeita 'expoente incompleto' 'double x = 1e+;'
testar rejeita 'numero malformado' 'float x = 1.2.3;'
testar rejeita 'string com quebra de linha' $'print("ola\nmundo");'
testar rejeita 'comentario aberto em programa vazio' '/* sem fim'
testar rejeita 'comentario aberto apos programa valido' 'print(1); /* sem fim'
testar rejeita 'for fora do escopo' 'for (;;) {}'

printf '\nResultado do escopo: %d/%d testes passaram.\n' "$((total - falhas))" "$total"
((falhas == 0))
