# Consigna TP

Este ejercicio es una variante del conocido “BombLab”. En el ejercicio de BombLab clásico, un ejecutable “bomba” solicita claves de distinto tipo para desactivar 6 etapas. Ingresando la clave correcta de cada etapa se pasa a la etapa siguiente hasta ingresar las 6 claves y desactivar la bomba. Si se ingresa una clave incorrecta, la bomba “estalla” y es necesario volver a ejecutarla.

La forma de resolver el ejercicio es hacer ingeniería inversa sobre el código del ejecutable para encontrar las claves, ya que las mismas se encuentran precodificadas dentro del ejecutable.

En este ejercicio las claves no están precodificadas, sino que se generan aleatoriamente cada vez que se ejecuta la “bomba”, por lo que la ingeniería inversa debe hacerse en tiempo de ejecución para encontrar las claves generadas.

Se pide realizar la ingeniería inversa en tiempo de ejecución escribiendo un programa en lenguaje C que ejecute la “bomba” y mediante uso de PTRACE “lea” las claves en tiempo de ejecución e inyecte las claves directamente en los registros apropiados en el momento correspondiente de ejecución. La ejecución correcta de este programa desactivando las 6 etapas, junto con un informe detallando los pasos seguidos para generar el programa en C, generan la aprobación del trabajo práctico. Junto con el informe se debe entregar el código fuente del programa que desactiva las 6 etapas, junto con sus instrucciones de compilación y ejecución.

La fecha de entrega del informe y el programa es hasta las 23.59hs del miércoles 17 de junio de 2026. La entrega se realiza subiendo el informe y el programa a través del campus de la
materia.

# Nota de Este TP:

10
