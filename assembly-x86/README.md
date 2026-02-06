# Lenguaje Ensamblador Intel x86

## Generar archivo objeto en formato ELF de 64 bits

`nasm -f elf64 programa.asm -o programa.o`

## Enlazar con GCC

`gcc -no-pie programa.o -o programa`
