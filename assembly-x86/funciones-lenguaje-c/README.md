# Funciones de Lenguje C en Assembly Intel x86

## Como Invocarlas (en Linux) 

Las funciones de C tienen esta estructura:

```C
tipo funcion(p1, p2, p3, p4, p5, p6, ...);

// tipo = tipo de dato que devuelve la función
// p = parametro
```

Para pasar los parametros a las funciones de C se deben hacer uso de los registros. La elección de estos registros no es trivial.

- `tipo: rax`
- `p1: rdi`
- `p2: rsi`
- `p3: rdx`
- `p4: rcx`
- `p5: r8`
- `p6: r9`
