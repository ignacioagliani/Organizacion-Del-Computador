# Ejercicios de Parcial de Lenguaje Ensamblador para Procesadores de Arquitectura Intel x86

# 1.asm

Se cuenta con una matriz (M) de 50 filas x 9 columnas que contiene información de la participación de 50 países en los últimos 9 mundiales de fútbol. Cada fila representa un país y cada columna un año de mundial.

Cada elemento de M tiene 2 bytes de longitud e indica hasta qué instancia llegó un país en un mundial o si no participó.

Además se cuenta con un archivo llamado "mundiales.dat" que contiene la información para el llenado de M. Cada registro tiene los siguientes campos:

- Código de país: 1 byte en binario de punto fijo sin signo (1 a 50)
- Año de mundial: 2 bytes en binario de punto fijo sin signo (1986, 1990, 1994, 1998, 2002, 2006, 2010, 2014, 2018)
- Código de instancia: 2 bytes en formato caracteres ASCII siendo:
  - NP: no participó
  - FG: fase de grupos
  - OF: octavos de final
  - CF: cuartos de final
  - SF: semifinal
  - FI: final

Se pide realizar un programa en assembler Intel 80x86 que resuelva lo siguiente:

1. Lea los registros del archivo y los valide todos sus campos mediante una rutina interna llamada VALREG
2. Llene la matriz con la información de los registros válidos (los registros inválidos serán descartados). Los elementos que no puedan llenarse con la información del archivo deberán quedar con valor default (ej: caracteres asterisco o algo similar)
3. Solicite ingresar un código de país por teclado (no es requerido validarlo) y muestre por pantalla cuántas veces NO quedó dicho país entre los 4 mejores (NO llegar a semifinal ni final)

# 2.asm
Dado un archivo en formato BINARIO que contiene informacion sobre autos llamado listado.dat
donde cada REGISTRO del archivo representa informacion de un auto con los campos:

* marca:                10 caracteres
* año de fabricacion:    4 caracteres
* patente:               7 caracteres
* precio                 7 caracteres

Se pide codificar un programa en assembler intel que lea cada registro del archivo listado y guarde
en un nuevo archivo en formato binario llamado seleccionados.dat las patentes y el precio (en bpfc/s 4 bytes) de aquellos autos cuyo año de fabricación esté entre 2010 y 2020 inclusive
Como los datos del archivo pueden ser incorrectos, se deberan validar mediante una rutina interna.
Se deberá validar Marca (que sea Fiat, Ford, Chevrolet o Peugeot), año (que sea un valor
numérico y que cumpla la condicion indicada del rango) y precio que sea un valor numerico.

# 3.asm

Se cuenta con un archivo en formato binario llamado ENCUESTA.DAT que contiene información de las respuestas de una encuesta que consultaba a empleados de 10 compañías cuál es el recurso más importante que el empleador debía pagar para facilitar el trabajo remoto y daba para elegir 4 opciones (Internet, Computadora, Silla, Luz). Cada registro del archivo representa la respuesta de un empleado y contiene la siguiente información:

*   Código de recurso: 2 bytes en formato ASCII (IN, CO, SI, LU)
*   Código de compañía: 1 byte en formato binario punto fijo sin signo (1 a 10)

Se pide realizar un programa en assembler Intel que:

1. Lea el archivo y por cada registro llene una matriz (M) de 4x10 donde cada fila representa a un recurso y cada columna una compañía. Cada elemento de M es un binario de punto fijo sin signo de 2 bytes y representa la sumatoria de respuestas para cada recurso en cada compañía;
2. Validar los datos del registro mediante una rutina interna (VALREG) para que puedan ser descartados los inválidos.
3. Padrón PAR: ingresar por teclado un código de recurso e informar por pantalla la compañía que más lo eligió y que % representa del total. Padrón IMPAR: ingresar por teclado un código de compañía e informar por pantalla el recurso con mayor cantidad de votos y que % representa del total.

# 4.asm

Se dispone de una matriz de 30x10 que representa un tablero de Tetris (30 de alto y 10
de largo).Cada elemento de la matriz indica si ese punto del tablero está ocupado o no
siendo  "*"; (asterisco) ocupado y "" (espacio en blanco) en caso contrario.
Para cargar el tablero se hará uso de un archivo (FICHAS.DAT) que contiene el
posicionamiento inicial de las fichas. Solo hay fichas de tipo "|" (dimensión 4x1) y cada
registro del archivo tiene los siguientes campos:
●  Fila: CL2 (Indica la fila de la posición inicial de la ficha - 1..30)
●  Columna: BL1 (Indica la columna de la posición inicial de la ficha - 1..10)
●  Sentido: CL1 (Indica el sentido hacia donde continúan el resto de las posiciones que
ocupa la ficha en el tablero   A - Arriba; B - Abajo; D - Derecha; I - Izquierda)
Se pide realizar un programa en assembler Intel 8086 que realice la carga del tablero
(se asume que las fichas no solapan). Como la información del archivo puede ser
incorrecta se deberá validar haciendo uso de una rutina interna (VALFICHA) para
descartar los inválidos. La rutina deberá validar todos los campos del registro (tipo de
datos, valores y que la ficha quepa en el tablero)  

Se pide
1. Carga del tablero
2. Codificación de rutina interna VALFICHA
3. Para aquellos alumnos con padrón PAR se deben imprimir los nros de filas
donde todos los elementos tienen * mientras que los alumnos con padrón IMPAR
los nros de columnas donde todos tiene *.
