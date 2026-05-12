# Máquina Elementar Abacus

## Ejercicio 1
Se tiene una lista (L) cuya dirección de inicio se encuentra almacenada en la celda 200(16) que representa las ventas de teléfonos celulares. Cada nodo de la lista (L) está formado por 3 celdas contiguas en memoria:

* La primera celda contiene el modelo del celular.
* La segunda celda contiene el número de serie del celular.
* La última celda contiene la dirección del siguiente nodo de la lista. El final de la lista (L) se indica con un valor -1 en la última celda del último nodo.

Se pide realizar un programa ABACUS con punto de carga en la celda 300(16) que recorra la lista (L) y genere un vector (V) que comience en la celda 100(16) cuyo contenido sean los número de serie de aquellos celulares cuyo modelo coincida con el especificado en la celda 400(16). Por otro lado dejar en la celda 401(16) la cantidad total vendida de dicho modelo.

Datos de la máquina: L(RPI) = 12 bits; L(CO) = 4 bits

```
Código de operaciones:
0 – Carga inmediata
1 – Carga
2 – Almacenar
3 – Suma
4 – Not (AC)
7 – Bifurcación si (AC) = 0
8 – Bifurcación si (AC) > 0
9 – Bifurcación si (AC) < 0
F – Fin de programa
```

## Ejercicio 2
Se tiene una lista (L) cuya dirección de inicio se encuentra almacenada en la celda 200(16) que representa las novedades de COVID-19 de todas las provincias en el territorio argentino en las últimas 24hrs. Cada nodo de la lista (L) está formado por 4 celdas contiguas en memoria:

* La primera celda contiene el Id de la provincia.
* La segunda celda contiene el tipo de dato relacionado con la novedad: (-1: Fallecido, 0: Recuperado, 1: Contagiado).
* La tercera celda contiene la cantidad registrada en las últimas 24hrs en la provincia.
* La última celda contiene la dirección del siguiente nodo de la lista. El final de la lista (L) se indica con un valor -1 en la última celda del último nodo.

Se pide realizar un programa ABACUS con punto de carga en la celda 300(16) que recorra la lista (L) y genere un vector (V) que comience en la celda 100(16) cuyo contenido sean los Ids de provincias que no hayan registrado ningún (PADRÓN PAR: CONTAGIADO) o (PADRÓN IMPAR: FALLECIDO) en las últimas 24hrs.

Por favor escriba su número de padrón de forma clara para realizar este ejercicio.

Por otro lado dejar en la celda 400(16) la cantidad total de recuperados en las últimas 24hrs.

Datos de la máquina: L(RPI) = 12 bits; L(CO) = 4 bits

```
Código de operaciones:
0 – Carga inmediata
1 – Carga
2 – Almacenar
3 – Suma
4 – Not (AC)
7 – Bifurcación si (AC) = 0
8 – Bifurcación si (AC) > 0
9 – Bifurcación si (AC) < 0
F – Fin de programa
```

## Ejercicio 3
Se tiene una lista (L) cuya dirección de inicio se encuentra almacenada en la celda 200(16). Esta lista representa las habitaciones de un hostal. Cada nodo de la lista (L) está formado por 3 celdas contiguas en memoria:
* La primera celda contiene un número de habitación del hostal.
* La segunda celda contiene la cantidad de camas libres en la habitación.
* La última celda contiene la dirección del siguiente nodo de la lista. El final de la lista (L) se indica con un valor -1 en la última celda del último nodo.

Por otro lado se tiene un vector (V) que comienza en la celda 100(16) que contiene las novedades diarias de ocupación/desocupación de camas del hostal. El vector tiene tres celdas contiguas en memoria:
* La primera celda contiene un número de habitación del hostal.
* La segunda celda te indica si la novedades es de ocupación (0) o desocupación (1)
* La tercera celda contiene la cantidad de camas a ocupar o desocupar en la habitación. El final del vector se representa con un -1 en la primera celda.

Se pide realizar un programa ABACUS con punto de carga en la celda 300(16) que recorra el vector (V) y actualice las camas libres de las habitaciones del hostal, teniendo en cuenta que tanto la lista (L) como el vector (V) están ordenados por número de habitación y que no hay ninguna habitación en el vector (V) que no esté en la lista
