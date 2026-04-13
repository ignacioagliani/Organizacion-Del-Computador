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
