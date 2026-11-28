# Como usar

## Pré-requisitos

No Linux ou WSL, instale as ferramentas necessárias:

```bash
sudo apt update
sudo apt install -y build-essential flex bison make python3-pip
```

## Compilar

Na raiz do repositório, execute:

```bash
make
```

Esse comando gera `build/analisador` usando o analisador léxico (`src/analisador-lexico/scanner.l`), o parser (`src/parser.y`), a AST (`src/ast.c`), a tabela de símbolos (`src/tabela.c`) e o interpretador (`src/interpretador.c`).

## Executar

Para analisar um arquivo:

```bash
./build/analisador examples/variaveis.c
```

Para fornecer o programa diretamente pelo terminal:

```bash
printf '%s\n' 'int y = 1; int z = 2; int x = y + z;' | ./build/analisador
```

Quando a entrada é aceita, o analisador imprime `Analise sintatica concluida com sucesso.`, a árvore sintática abstrata e a tabela de símbolos. Se encontrar um erro léxico, sintático ou semântico, informa o problema e retorna um código de saída diferente de zero.

Para executar o programa em vez de imprimir a AST e a tabela:

```bash
./build/analisador --run examples/interpretador.c
printf '%s\n' 'int i = 0; while (i < 3) { print("valor", i); i++; }' | ./build/analisador --run
```

O modo `--run` implementa variáveis escalares, expressões, atribuições, incremento/decremento, blocos, `if`/`else`, `while` e `print`. Definições e chamadas de funções estão fora do escopo; uma definição ainda pode ser reconhecida pela gramática, mas é ignorada durante a execução.

## Testes

Para executar todas as suítes, incluindo os testes de execução do interpretador:

```bash
make test
```

Os scripts de teste usam quebras de linha LF. O arquivo `.gitattributes` preserva esse formato quando o Git extrai os arquivos. Se uma cópia existente no Windows apresentar um erro de Bash com `\r`, use uma cópia nova do repositório ou converta para LF os arquivos `.sh` em `tests/`.

Para rodar apenas a suíte de execução após compilar:

```bash
bash tests/test_interpretador.sh ./build/analisador
```

Para executar apenas os quatro testes estruturais da AST:

```bash
bash tests/test_ast.sh ./build/analisador
```

## Pré-visualizar a documentação

```bash
pip install -r requirements-docs.txt
mkdocs serve
```

## Limpar arquivos gerados

```bash
make clean
```
