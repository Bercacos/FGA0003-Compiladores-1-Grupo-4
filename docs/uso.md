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

Esse comando gera `build/analisador` usando o analisador léxico (`src/analisador-lexico/scanner.l`), o parser (`src/parser.y`), a AST (`src/ast.c`) e a tabela de símbolos (`src/tabela.c`).

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

O analisador ainda não executa as instruções do programa recebido.

## Testes

Para executar todas as suítes, incluindo os testes da AST, da tabela de símbolos e da análise semântica:

```bash
make test
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