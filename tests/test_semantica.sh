#!/usr/bin/env bash
# Analise semantica (AST + tabela): uso de identificadores, tipos e anotacao da AST.
set -u
analisador="${1:-./build/analisador}"
falhas=0
total=0
if [[ ! -x "$analisador" ]]; then
    printf 'Analisador nao encontrado ou nao executavel: %s\n' "$analisador" >&2
    exit 1
fi

# aceita "codigo" -> sem erros (status 0)
aceita() {
    local nome="$1" codigo="$2" saida rc
    total=$((total + 1))
    saida=$(printf '%s\n' "$codigo" | "$analisador" 2>&1); rc=$?
    if ((rc == 0)); then printf 'OK  %s\n' "$nome"
    else printf 'FALHOU  %s (status %s)\n%s\n' "$nome" "$rc" "$saida"; falhas=$((falhas + 1)); fi
}
# erro "codigo" "regex" -> status != 0 e a mensagem casa com a regex
erro() {
    local nome="$1" codigo="$2" regex="$3" saida rc
    total=$((total + 1))
    saida=$(printf '%s\n' "$codigo" | "$analisador" 2>&1); rc=$?
    if ((rc != 0)) && grep -Eq "$regex" <<<"$saida"; then printf 'OK  %s\n' "$nome"
    else printf 'FALHOU  %s (status %s)\n%s\n' "$nome" "$rc" "$saida"; falhas=$((falhas + 1)); fi
}
# ast "codigo" "regex" -> a AST impressa casa com a regex (tipo anotado)
ast() {
    local nome="$1" codigo="$2" regex="$3" saida
    total=$((total + 1))
    saida=$(printf '%s\n' "$codigo" | "$analisador" 2>&1)
    if grep -Eq "$regex" <<<"$saida"; then printf 'OK  %s\n' "$nome"
    else printf 'FALHOU  %s\n%s\n' "$nome" "$saida"; falhas=$((falhas + 1)); fi
}

# --- validos (estilo valido_01 / valido_02 da semana 7)
aceita 'declaracao e atribuicao' $'int a;\na = 3 + 5;'
aceita 'atribuicao direta' $'int b;\nb = 42;'
aceita 'int recebe char e float recebe int' $'char c = 65; float f = 1; int i = \'a\';'
aceita 'parametro usado no corpo' 'int f(int p) { return p + 1; }'
aceita 'variavel global usada em funcao' $'int g;\nvoid f(void) { g = 2; }'
aceita 'local oculta global com outro tipo' $'int x;\nvoid f(void) { string x; x = "a"; }'
aceita 'comparacao de strings' $'string s = "a"; int r = s == s;'
aceita 'incremento em variavel' 'int i; i++; --i;'

# --- identificador nao declarado (erro_nao_declarada)
erro 'atribuicao a nao declarada' 'x = 10;' "identificador 'x' nao declarado"
erro 'uso em expressao' 'int a; a = b + 1;' "identificador 'b' nao declarado"
erro 'uso em inicializacao' 'int a = z;' "identificador 'z' nao declarado"
erro 'incremento de nao declarada' '++k;' "identificador 'k' nao declarado"
erro 'variavel de bloco fora do bloco' $'{ int t; }\nt = 1;' "identificador 't' nao declarado"
erro 'variavel de outra funcao' $'void f(void) { int a; }\nvoid g(void) { a = 1; }' "identificador 'a' nao declarado"
erro 'uso de funcao como variavel' $'void f(void) { }\nint x = f;' "'f' e uma funcao"

# --- redeclaracao (erro_redeclaracao)
erro 'redeclaracao' $'int a;\nint a;' "'a' ja declarado"

# --- tipos (erro_tipo)
erro 'string em int' $'int a;\na = "texto";' 'tipos incompativeis na atribuicao a .a. \(int = string\)'
erro 'inicializacao com tipo errado' 'int a = "x";' 'tipos incompativeis na atribuicao'
erro 'int em string' 'string s = 1;' 'string = int'
erro 'soma int com string' 'int a; int b = a + "x";' "tipos incompativeis para '\+'"
erro 'modulo com float' 'float f; int r = f % 2;' "tipos incompativeis para '%'"
erro 'menos unario em string' 'int a = -"x";' "operando invalido para '-'"
erro 'incremento em string' 'string s; s++;' "exige variavel numerica"
erro 'condicao string' 'if ("a") { }' 'condicao invalida'
erro 'while com condicao string' 'while ("a") { }' 'condicao invalida'
erro 'erro nao propaga em cascata' 'int a = x + 1;' '^1 erro\(s\) semantico'

# --- AST anotada com tipos
ast 'id anotado com tipo do simbolo' 'float f; f = f + 1;' 'Id f : float'
ast 'binop promove para float' 'int i; float f; f = i + f;' 'BinOp \+ : float'
ast 'binop int com int' 'int a; a = a * 2;' 'BinOp \* : int'
ast 'comparacao e int' 'double d; int r = d < 1.5;' 'BinOp < : int'
ast 'atribuicao anotada' 'float f; f = 1;' 'Atrib f : float'
ast 'literal com tipo' 'int a = 3;' 'Num 3 : int'
ast 'unario anotado' 'double d; d = -d;' 'UnOp - : double'
ast 'pos-incremento anotado' 'char c; c++;' 'PosInc \+\+ : char'

printf '\nAnalise semantica: %d/%d testes passaram.\n' "$((total - falhas))" "$total"
((falhas == 0))
