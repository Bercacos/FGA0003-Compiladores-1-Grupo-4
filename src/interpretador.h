#ifndef INTERPRETADOR_H
#define INTERPRETADOR_H

#include "ast.h"

/* Executa a AST. Retorna 0 se der certo e 1 se ocorrer um erro. */
int interpretar(const No *raiz);

#endif