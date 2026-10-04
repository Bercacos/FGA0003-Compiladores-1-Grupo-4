# Como usar

## Pré-requisitos

No Linux ou WSL:

```bash
sudo apt update
sudo apt install -y build-essential flex bison make python3-pip
```

Para pré-visualizar a documentação localmente:

```bash
pip install -r requirements-docs.txt
mkdocs serve
```

## Compilar

Na raiz do repositório:

```bash
make
```

Isso gera o binário `build/analisador` a partir de `src/analisador-lexico/scanner.l` e `src/parser.y`.

## Executar

Arquivo de entrada:

```bash
./build/analisador examples/variaveis.c
```

Entrada via stdin:

```bash
echo 'int x = y + z;' | ./build/analisador
```

Saída esperada em caso de sucesso:

```text
Analise sintatica concluida com sucesso.
```

Em caso de erro, o programa imprime mensagem léxica e/ou sintática com indicação de linha e retorna código de saída diferente de zero.

## Testes

Suíte principal:

```bash
make test
```

Suíte adicional (inclui `if`, funções e `return`):

```bash
bash tests/teste_parser_extra.sh ./build/analisador
```

## Limpar artefatos

```bash
make clean
```
