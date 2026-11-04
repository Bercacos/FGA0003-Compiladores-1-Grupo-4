CC := gcc
CFLAGS := -Wall -Wextra -std=gnu11
SRC_DIR := src
BUILD_DIR := build
TARGET := $(BUILD_DIR)/analisador

.PHONY: all run test clean
all: $(TARGET)

TABELA_SRC := $(SRC_DIR)/tabela.c
TABELA_HDR := $(SRC_DIR)/tabela.h $(SRC_DIR)/tipos.h

$(TARGET): $(BUILD_DIR)/parser.tab.c $(BUILD_DIR)/lex.yy.c $(TABELA_SRC) $(TABELA_HDR) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -I$(BUILD_DIR) -I$(SRC_DIR) $(filter %.c,$^) -o $@

$(BUILD_DIR)/test_tabela: tests/test_tabela.c $(TABELA_SRC) $(TABELA_HDR) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -I$(SRC_DIR) tests/test_tabela.c $(TABELA_SRC) -o $@

$(BUILD_DIR)/parser.tab.c $(BUILD_DIR)/parser.tab.h: $(SRC_DIR)/parser.y | $(BUILD_DIR)
	bison -Wall -d -o $(BUILD_DIR)/parser.tab.c $<

$(BUILD_DIR)/lex.yy.c: $(SRC_DIR)/analisador-lexico/scanner.l $(BUILD_DIR)/parser.tab.h | $(BUILD_DIR)
	flex -o $@ $<

$(BUILD_DIR):
	mkdir -p $@

# Testes da tabela de simbolos (rodam junto com "make test")
.PHONY: test-tabela
test-tabela: $(TARGET) $(BUILD_DIR)/test_tabela
	bash tests/test_tabela.sh ./$(TARGET)
	./$(BUILD_DIR)/test_tabela
test: test-tabela

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	bash tests/test_parser.sh ./$(TARGET)

clean:
	rm -rf $(BUILD_DIR)
