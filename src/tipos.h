#ifndef TIPOS_H
#define TIPOS_H

/*
 * FGA0003 - Compiladores 1 - Grupo 4
 * Tipos da linguagem (subconjunto de C) usados pela tabela de simbolos
 * e, futuramente, pela AST e pela analise semantica.
 */

typedef enum {
    TIPO_INT,
    TIPO_FLOAT,
    TIPO_DOUBLE,
    TIPO_CHAR,
    TIPO_STRING,
    TIPO_VOID
} Tipo;

static inline const char *tipo_para_texto(Tipo tipo) {
    switch (tipo) {
        case TIPO_INT:    return "int";
        case TIPO_FLOAT:  return "float";
        case TIPO_DOUBLE: return "double";
        case TIPO_CHAR:   return "char";
        case TIPO_STRING: return "string";
        case TIPO_VOID:   return "void";
    }
    return "?";
}

#endif
