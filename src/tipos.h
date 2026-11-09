#ifndef TIPOS_H
#define TIPOS_H

/*
 * FGA0003 - Compiladores 1 - Grupo 4
 * Tipos da linguagem (subconjunto de C) usados pela tabela de simbolos
 * e, futuramente, pela AST e pela analise semantica.
 */

/* Tipo de dados anotado nos nos da AST e nos simbolos. TIPO_DESCONHECIDO (0) e
 * o valor inicial; a analise semantica o preenche. */
typedef enum {
    TIPO_DESCONHECIDO,
    TIPO_INT,
    TIPO_FLOAT,
    TIPO_DOUBLE,
    TIPO_CHAR,
    TIPO_STRING,
    TIPO_VOID,
    TIPO_ERRO
} Tipo;

static inline const char *tipo_para_texto(Tipo tipo) {
    switch (tipo) {
        case TIPO_INT:    return "int";
        case TIPO_FLOAT:  return "float";
        case TIPO_DOUBLE: return "double";
        case TIPO_CHAR:   return "char";
        case TIPO_STRING: return "string";
        case TIPO_VOID:   return "void";
        case TIPO_DESCONHECIDO: return "?";
        case TIPO_ERRO:   return "erro";
    }
    return "?";
}

#endif
