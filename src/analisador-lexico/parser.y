%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
%}

%union {
    int    ival;
    double dval;
    char  *sval;
}

/* Tokens com valor semântico */
%token <sval> IDENT STRINGLIT
%token <dval> NUMBER
%token <ival> CHARLIT

/* Palavras reservadas */
%token KW_IF KW_WHILE KW_FOR KW_ELSE KW_RETURN
%token KW_INT KW_FLOAT KW_CHAR KW_STRING KW_DOUBLE KW_VOID

/* Pontuação */
%token LPAREN RPAREN LCHAVE RCHAVE LCOLCH RCOLCH
%token PONTOVIR VIRGULA

/* Operadores */
%token ASSIGN
%token MENEQ MAIOREQ DIFER EQ MENOR MAIOR
%token INCRE DECRE
%token PLUS MINUS TIMES DIVIDE

/* Precedência e associatividade */
%right ASSIGN
%left  EQ DIFER
%left  MENOR MAIOR MENEQ MAIOREQ
%left  PLUS MINUS
%left  TIMES DIVIDE
%right INCRE DECRE
%nonassoc UMINUS

/* Resolve o conflito clássico do "dangling else" associando
   o else ao if mais próximo (comportamento igual ao de C). */
%nonassoc SEM_ELSE
%nonassoc KW_ELSE

%%

programa:
      lista_declaracoes
    ;

lista_declaracoes:
      /* vazio */
    | lista_declaracoes declaracao
    ;

declaracao:
      declaracao_variavel
    | comando
    ;

tipo:
      KW_INT
    | KW_FLOAT
    | KW_CHAR
    | KW_STRING
    | KW_DOUBLE
    | KW_VOID
    ;

declaracao_variavel:
      tipo IDENT PONTOVIR
    | tipo IDENT ASSIGN expr PONTOVIR
    ;

bloco:
      LCHAVE lista_declaracoes RCHAVE
    ;

comando:
      expr PONTOVIR
    | bloco
    | KW_IF LPAREN expr RPAREN comando %prec SEM_ELSE
    | KW_IF LPAREN expr RPAREN comando KW_ELSE comando
    | KW_WHILE LPAREN expr RPAREN comando
    | KW_FOR LPAREN expr PONTOVIR expr PONTOVIR expr RPAREN comando
    | KW_RETURN PONTOVIR
    | KW_RETURN expr PONTOVIR
    ;

expr:
      expr ASSIGN expr
    | expr EQ expr
    | expr DIFER expr
    | expr MENOR expr
    | expr MAIOR expr
    | expr MENEQ expr
    | expr MAIOREQ expr
    | expr PLUS expr
    | expr MINUS expr
    | expr TIMES expr
    | expr DIVIDE expr
    | MINUS expr %prec UMINUS
    | INCRE expr
    | DECRE expr
    | expr INCRE
    | expr DECRE
    | LPAREN expr RPAREN
    | IDENT
    | NUMBER
    | STRINGLIT
    | CHARLIT
    ;

%%

int main(void) {
    /* Poderiamos exibir instrucoes, se quiser */
    printf("Digite expressoes, terminadas com ';'. Pressione Ctrl+D para encerrar.\n");
    return yyparse();
}

void yyerror(const char *s) {
    /* Mensagem de erro padrao de Bison */
    fprintf(stderr, "Erro sintatico: %s\n", s);
}
