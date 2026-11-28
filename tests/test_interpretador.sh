#!/usr/bin/env bash
# Interpretador: executa programas com --run e confere a saida (stdout) e o status.
# make && bash tests/test_interpretador.sh ./build/analisador
set -u
analisador="${1:-./build/analisador}"
falhas=0
total=0
if [[ ! -x "$analisador" ]]; then
    printf 'Analisador nao encontrado ou nao executavel: %s\n' "$analisador" >&2
    exit 1
fi

# roda "codigo" 
roda() {
    local nome="$1" codigo="$2" esperado="$3" saida rc
    total=$((total + 1))
    saida=$(printf '%s\n' "$codigo" | "$analisador" --run 2>/dev/null); rc=$?
    if ((rc == 0)) && [[ "$saida" == "$esperado" ]]; then printf 'OK  %s\n' "$nome"
    else printf 'FALHOU  %s (status %s)\n--- esperado\n%s\n--- obtido\n%s\n' "$nome" "$rc" "$esperado" "$saida"; falhas=$((falhas + 1)); fi
}
# falha "codigo"
falha() {
    local nome="$1" codigo="$2" regex="$3" erro rc
    total=$((total + 1))
    erro=$(printf '%s\n' "$codigo" | "$analisador" --run 2>&1 >/dev/null); rc=$?
    if ((rc != 0)) && grep -Eq "$regex" <<<"$erro"; then printf 'OK  %s\n' "$nome"
    else printf 'FALHOU  %s (status %s)\n%s\n' "$nome" "$rc" "$erro"; falhas=$((falhas + 1)); fi
}

# --- aritmetica e tipos ---
roda "aritmetica basica" 'int a = 10; int b = 3; print(a + b, a - b, a * b);' '13 7 30'
roda "divisao inteira trunca" 'print(7 / 2);' '3'
roda "divisao real" 'print(7.0 / 2);' '3.5'
roda "int recebe real e trunca" 'int m = 7.9; print(m);' '7'
roda "float recebe divisao inteira" 'float f = 7 / 2; print(f);' '3'
roda "double soma" 'double d = 1.5 + 2; print(d);' '3.5'
roda "modulo" 'print(10 % 3, 2 * 3 % 4);' '1 2'
roda "precedencia e parenteses" 'print((1 + 2) * 3, 10 - 2 - 3, 1 + 2 * 3);' '9 5 7'
roda "menos unario e negacao" 'int a = 10; print(-a, !a, !0);' '-10 0 1'

# --- char e string ---
roda "char imprime caractere" "char c = 'A'; print(c);" 'A'
roda "char incrementa" "char c = 'A'; c++; print(c);" 'B'
roda "char recebe codigo" 'char q = 65; print(q);' 'A'
roda "string com escape" 'string s = "oi\tmundo"; print(s, "x");' $'oi\tmundo x'
roda "string reatribuida" 'string s = "a"; s = "b"; print(s);' 'b'
roda "comparacao de strings" 'print("a" == "a", "a" != "a", "a" == "b");' '1 0 0'

# --- comparacoes e logicos ---
roda "relacionais" 'print(1 < 2, 2 <= 2, 3 > 4, 4 >= 5, 1 == 1, 1 != 1);' '1 1 0 0 1 0'
roda "&& e ||" 'print(1 && 0, 1 || 0, 0 || 0, 1 && 1);' '0 1 0 1'
roda "|| curto-circuito" 'print(1 || 1 / 0);' '1'
roda "&& curto-circuito" 'print(0 && 1 / 0);' '0'

# --- ++ e -- ---
roda "pre e pos incremento" 'int k = 5; print(k++, ++k, k--, --k);' '5 7 7 5'
roda "incremento como comando" 'int i = 0; i++; i++; print(i);' '2'

# --- controle de fluxo ---
roda "while" 'int i = 0; while (i < 3) { print(i); i++; }' $'0\n1\n2'
roda "while sem iteracao" 'int i = 5; while (i < 3) print(i); print("fim");' 'fim'
roda "fatorial com while" 'int f = 1; int n = 5; while (n > 1) { f = f * n; n = n - 1; } print(f);' '120'
roda "if verdadeiro" 'if (2 > 1) print("sim"); else print("nao");' 'sim'
roda "if falso com else" 'if (1 > 2) print("sim"); else print("nao");' 'nao'
roda "if falso sem else" 'if (0) print("sim"); print("fim");' 'fim'
roda "else if encadeado" 'int x = 2; if (x == 1) print("um"); else if (x == 2) print("dois"); else print("outro");' 'dois'
roda "while aninhado" 'int i = 0; while (i < 2) { int j = 0; while (j < 2) { print(i, j); j++; } i++; }' $'0 0\n0 1\n1 0\n1 1'

# --- escopo e declaracoes ---
roda "bloco oculta variavel externa" 'int a = 1; { int a = 99; print(a); } print(a);' $'99\n1'
roda "bloco altera variavel externa" 'int a = 1; { a = 2; } print(a);' '2'
roda "multiplos declaradores" 'int a = 1, b = 2, c; c = a + b; print(c);' '3'
roda "declaracao sem valor e atribuicao" 'int u; u = 4; print(u);' '4'
roda "print varios argumentos" 'print("x", 1, 2.5);' 'x 1 2.5'

# --- erros de execucao ---
falha "divisao por zero" 'int z = 1 / 0;' 'divisao por zero'
falha "modulo por zero" 'int z = 1 % 0;' 'resto de divisao por zero'
falha "variavel sem valor" 'int u; print(u);' "variavel 'u' sem valor"
falha "incremento sem valor" 'int u; u++;' "variavel 'u' sem valor"

# --- sem --run nao executa ---
total=$((total + 1))
saida=$(printf '%s\n' 'print("oi");' | "$analisador" 2>/dev/null)
if [[ "$saida" == *"Analise sintatica concluida"* && "$saida" != *$'\noi' ]]; then echo "OK  sem --run apenas analisa"
else printf 'FALHOU  sem --run apenas analisa\n%s\n' "$saida"; falhas=$((falhas + 1)); fi

# --- erro semantico impede a execucao ---
total=$((total + 1))
saida=$(printf '%s\n' 'print("antes"); int x = "texto";' | "$analisador" --run 2>/dev/null); rc=$?
if ((rc != 0)) && [[ "$saida" != *antes* ]]; then echo "OK  erro semantico impede execucao"
else printf 'FALHOU  erro semantico impede execucao (status %s)\n%s\n' "$rc" "$saida"; falhas=$((falhas + 1)); fi

printf '\nInterpretador: %d/%d testes passaram.\n' "$((total - falhas))" "$total"
((falhas == 0))
