// Exemplo para testar o interpretador:
//   ./build/analisador --run examples/interpretador.c

int a = 10;
int b = 3;
print("soma:", a + b);
print("divisao inteira:", a / b);
print("resto:", a % b);

float f = 7.0 / 2;
print("divisao real:", f);

char letra = 'A';
letra++;
print("proxima letra:", letra);

string nome = "mundo";
print("ola,", nome);
print("strings iguais?", nome == "mundo");

if (a > b && b > 0) {
    print("a e maior que b");
} else {
    print("a nao e maior que b");
}

int i = 1;
while (i <= 3) {
    print("contagem:", i);
    i++;
}

int fat = 1;
int n = 5;
while (n > 1) {
    fat = fat * n;
    n = n - 1;
}
print("5! =", fat);

int x = 1;
{
    int x = 99;
    print("x dentro do bloco:", x);
}
print("x fora do bloco:", x);
