CC := gcc
CFLAGS := -Wall -Wextra -std=gnu11
SRC_DIR := src
BUILD_DIR := build
TARGET := $(BUILD_DIR)/analisador

.PHONY: all run test clean
all: $(TARGET)

$(TARGET): $(BUILD_DIR)/parser.tab.c $(BUILD_DIR)/lex.yy.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -I$(BUILD_DIR) $^ -o $@

$(BUILD_DIR)/parser.tab.c $(BUILD_DIR)/parser.tab.h: $(SRC_DIR)/parser.y | $(BUILD_DIR)
	bison -Wall -d -o $(BUILD_DIR)/parser.tab.c $<

$(BUILD_DIR)/lex.yy.c: $(SRC_DIR)/analisador-lexico/scanner.l $(BUILD_DIR)/parser.tab.h | $(BUILD_DIR)
	flex -o $@ $<

$(BUILD_DIR):
	mkdir -p $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	bash tests/test_parser.sh ./$(TARGET)

clean:
	rm -rf $(BUILD_DIR)
