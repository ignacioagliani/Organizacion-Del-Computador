# Guía de Ejercicios Lenguaje Ensamblador ARM

## Parte 1

### Práctica 1. Hola mundo
Escribir el código ARM que ejecutado bajo ARMSim# imprima el mensaje “Hola Mundo”

### Práctica 2. Mostrar cadenas de caracteres
Escribir el código ARM que ejecutado bajo ARMSim# imprima dos cadenas de caracteres predefinidas en memoria incluyendo salto de línea “Hola” y ”Chau” utilizando una subrutina que imprima un string cuya dirección esté en el R3.

### Práctica 3. Cálculos aritméticos y lógicos
Escribir el código ARM que ejecutado bajo ARMSim# realice las siguientes operaciones aritméticas y lógicas sobre dos números cargados en memoria: Suma, Resta, Multiplicación, AND, OR, XOR, Shift Izquierda, Shift Derecha, Shift Derecha Aritmética. Dejar el resultado de las operaciones en los registros del R2 al R10.

### Práctica 4. Entrada y Salida de entero
Escribir el código ARM que ejecutado bajo ARMSim# que lea un entero desde un archivo e imprima el mismo entero por pantalla.

### Práctica 5. Negar enteros desde archivo
Escribir el código ARM que ejecutado bajo ARMSim# lea dos enteros desde un archivo e imprima:
* El primer entero en su propia línea.
* El resultado de aplicar NOT al primer entero en su propia línea.
* El segundo entero en su propia línea.
* El resultado de aplicar NOT al segundo entero en su propia línea.

### Práctica 6. Mostrar cálculos aritméticos y lógicos
Escribir el código ARM que ejecutado bajo ARMSim# realice las siguientes operaciones aritméticas y lógicas sobre dos enteros almacenados en un archivo: Suma, Resta, Multiplicación, AND, OR, XOR, Shift Izquierda, Shift Derecha, Shift Derecha Aritmética. Imprimir por pantalla los resultados de las operaciones en sus propias líneas.

## Parte 2

### Práctica 7: Cálculo de valor absoluto con instrucciones condicionales
Escribir el código ARM que ejecutado bajo ARMSim# lea un entero desde un archivo e imprima el valor absoluto del entero. Utilizar instrucciones ejecutadas condicionalmente y no utilizar bifurcaciones condicionales.

### Práctica 8: Cálculo de valor absoluto con bifurcación
Escribir el código ARM que ejecutado bajo ARMSim# lea un entero desde un archivo e imprima el valor absoluto del entero. Utilizar bifurcaciones condicionales.

### Práctica 9: Cálculo de mínimo y máximo
Escribir el código ARM que ejecutado bajo ARMSim# lea dos enteros desde un archivo e imprima el mínimo y el máximo respectivamente de la siguiente manera:
```
Min: <mínimo>
Max: <máximo>
```
### Práctica 10. Cálculo de mediana
Escribir el código ARM que ejecutado bajo ARMSim# lea tres enteros desde un archivo e imprima la mediana, siendo la mediana el valor de la variable de posición central en un conjunto de datos ordenados. Por ejemplo, si los valores fueran 5, 8 y 9, la mediana sería 8.

### Práctica 11: Codificación de While
Escribir el código ARM que ejecutado bajo ARMSim# imprima los números del 0 al 9.

Pseudocódigo:
```
x = 0
while (x < 10) {
print x
x++
}
```

### Práctica 12: Cálculo de factorial
Escribir el código ARM que ejecutado bajo ARMSim# lea un entero desde un archivo, calcule el factorial de ese entero y muestre los valores intermedios del proceso. El algoritmo podría resumirse como:
```
n = <<entero leído desde archivo>>
accum = 1
while (n != 0) {
accum = accum * n
print accum
print "\n"
n = n - 1
}
print accum
print "\n"
```
Una salida aceptable del programa sería, para el caso que el valor de entrada fuera 5:
```
5
20
60
120
120
120
```
Puede asumirse que el archivo no contendrá un entero negativo.