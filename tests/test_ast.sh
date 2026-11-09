#!/usr/bin/env bash
set -u

analisador="${1:-./build/analisador}"
codigo='int a = 10; int b = 20; int soma = a + b * 2;'
saida=$(printf '%s\n' "$codigo" | "$analisador" 2>&1)
status=$?

esperado=$'      BinOp + : int  (linha 1)\n        Id a : int  (linha 1)\n        BinOp * : int  (linha 1)\n          Id b : int  (linha 1)\n          Num 2 : int  (linha 1)'

if (( status == 0 )) && [[ "$saida" == *"$esperado"* ]]; then
    echo "OK  AST preserva a precedencia de a + b * 2"
else
    echo "FALHOU  AST de a + b * 2"
    printf '%s\n' "$saida"
    exit 1
fi

codigo_if='int x = 1; if (x) { x = x + 2; } else { x = x - 1; }'
saida_if=$(printf '%s\n' "$codigo_if" | "$analisador" 2>&1)
status_if=$?

esperado_if=$(cat <<'AST'
  If  (linha 1)
    Id x : int  (linha 1)
    Bloco  (linha 1)
      Atrib x : int  (linha 1)
        BinOp + : int  (linha 1)
          Id x : int  (linha 1)
          Num 2 : int  (linha 1)
    Bloco  (linha 1)
      Atrib x : int  (linha 1)
        BinOp - : int  (linha 1)
          Id x : int  (linha 1)
          Num 1 : int  (linha 1)
AST
)

if (( status_if == 0 )) && [[ "$saida_if" == *"$esperado_if"* ]]; then
    echo "OK  AST representa if e else em blocos separados"
else
    echo "FALHOU  AST de if/else"
    printf '%s\n' "$saida_if"
    exit 1
fi

codigo_funcao='int soma(int a, int b) { return a + b; }'
saida_funcao=$(printf '%s\n' "$codigo_funcao" | "$analisador" 2>&1)
status_funcao=$?

esperado_funcao=$(cat <<'AST'
  Funcao soma  (linha 1)
    Tipo int  (linha 1)
    Param a  (linha 1)
      Tipo int  (linha 1)
    Param b  (linha 1)
      Tipo int  (linha 1)
    Bloco  (linha 1)
      Return  (linha 1)
        BinOp + : int  (linha 1)
          Id a : int  (linha 1)
          Id b : int  (linha 1)
AST
)

if (( status_funcao == 0 )) && [[ "$saida_funcao" == *"$esperado_funcao"* ]]; then
    echo "OK  AST representa funcao, parametros e return"
else
    echo "FALHOU  AST de funcao"
    printf '%s\n' "$saida_funcao"
    exit 1
fi

codigo_while='int x = 0; while (x < 3) { x = x + 1; }'
saida_while=$(printf '%s\n' "$codigo_while" | "$analisador" 2>&1)
status_while=$?

esperado_while=$(cat <<'AST'
  While  (linha 1)
    BinOp < : int  (linha 1)
      Id x : int  (linha 1)
      Num 3 : int  (linha 1)
    Bloco  (linha 1)
      Atrib x : int  (linha 1)
        BinOp + : int  (linha 1)
          Id x : int  (linha 1)
          Num 1 : int  (linha 1)
AST
)

if (( status_while == 0 )) && [[ "$saida_while" == *"$esperado_while"* ]]; then
    echo "OK  AST representa while, condicao e corpo"
else
    echo "FALHOU  AST de while"
    printf '%s\n' "$saida_while"
    exit 1
fi