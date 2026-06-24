# Trabajo Final - Teoria de la Computacion

## 1.1 Verificador de SAT en Imp

Se implemento un verificador de SAT en el lenguaje Imp. El programa recibe una formula en forma normal conjuntiva (CNF) y una interpretacion, y determina si la formula es satisfecha por dicha interpretacion. 

### Estrategia

El algoritmo funciona de la siguiente manera: 

- Se recorren todas las clausulas de la formula. 
- Para cada clausula, se verifican todos sus literales. 
- Una clausula es verdadera si al menos uno de sus literales es verdadero. 
- La formula completa es verdadera si todas las clausulas son verdaderas. 

Esto corresponde a aplicar OR en cada clausula y AND entre clausulas. La implementacion en Imp sigue este esquema utilizando las construcciones del lenguaje definidas en la especificacion formal. 

### Complejidad

Sea: 

- `m` la cantidad de clausulas. 
- `k` la cantidad de literales por clausula. 
- `n` la cantidad de variables en la interpretacion. 

La complejidad del algoritmo es:

`O(m * k * n)`

Esto se debe a que cada clausula recorre sus literales y, para evaluar cada literal, puede ser necesario recorrer linealmente la interpretacion para buscar el valor de una variable. Por lo tanto, el verificador opera en tiempo polinomial respecto al tamaño de la entrada. 

---

## 1.2 Codificacion de A en Maquina de Turing

En la primera parte del trabajo se definio el problema `A = SAT`, donde una instancia consiste en una formula booleana en CNF y se pregunta si existe una asignacion de valores de verdad que la haga verdadera. Por lo tanto, para esta parte se toma `DomA` como el conjunto de formulas en CNF. 

### Alfabeto

Se define el alfabeto:

`Σ = {0, 1, p, n, #, ;}`

donde: 

- `1` representa el sucesor en la codificacion de numeros naturales. 
- `0` representa el valor cero. 
- `p` representa un literal positivo. 
- `n` representa un literal negativo. 
- `#` separa literales dentro de una clausula. 
- `;` separa clausulas. 

### Codificacion

#### Variables

Las variables se codifican como una secuencia de unos: 

- `x1 -> 1` 
- `x2 -> 11` 
- `x3 -> 111` 

#### Literales

Los literales se codifican agregando un prefijo segun su signo: 

- `Pos(x2) -> p11` 
- `Neg(x3) -> n111` 

#### Clausula

Una clausula se representa como una secuencia de literales separados por `#`. Por ejemplo: 

`p1#n11#p111` 

#### Formula CNF

Una formula en CNF se representa como una secuencia de clausulas separadas por `;`. Por ejemplo: 

`p1#n11#p111 ; n1#p11#p111 ; p11#p111` 

### Maquina de Turing

Se especifica una maquina de Turing que decide SAT del siguiente modo: 

1. La maquina recibe una formula codificada en la cinta. 
2. Recorre la entrada e identifica las variables presentes. 
3. Genera no deterministicamente una interpretacion. 
4. Para cada clausula, verifica si al menos un literal es verdadero; si alguna clausula no tiene ningun literal verdadero, la maquina rechaza. 
5. Si todas las clausulas resultan verdaderas, la maquina acepta. 

---

## 2.1 Codificacion de la reduccion en Maquina de Turing

En la primera parte del trabajo se definieron los problemas: `A = SAT` y `B = Planificacion ciclica de tareas con restricciones`. En esta seccion se describe una reduccion polinomial desde SAT hacia el problema `B`. 

El objetivo es definir una transformacion:

`SAT ≤p B` 

### Idea de la reduccion

Dada una formula booleana `φ` en CNF, se construye una instancia del problema de planificacion de la siguiente forma: 

- Cada variable de `φ` se representa como una estacion. 
- Para cada variable, se crean decisiones que representan las posibles asignaciones de verdad. 
- Las clausulas se traducen a restricciones que aseguran que al menos una de las decisiones asociadas a sus literales quede satisfecha. 
- Se agregan restricciones de precedencia y exclusiones para impedir combinaciones inconsistentes. 
- El grafo de transiciones se construye de modo que una secuencia valida corresponda a una interpretacion consistente de la formula. 
---
### Correccion

Si `φ` es satisfacible, entonces existe una asignacion de valores de verdad que satisface todas sus clausulas. A partir de esa asignacion, se puede construir una secuencia ciclica de estaciones que respeta las restricciones del problema `B`. 

Si `φ` no es satisfacible, entonces no existe una asignacion que satisfaga simultaneamente todas las clausulas, y por lo tanto no es posible construir una secuencia valida que cumpla todas las restricciones de la instancia de `B`. 

Por lo tanto, la reduccion preserva satisfacibilidad. 

---
### Complejidad

La construccion de la instancia de `B` requiere recorrer las variables y las clausulas de la formula una cantidad polinomial de veces, agregando para cada una un numero acotado de componentes y restricciones. En consecuencia, la reduccion tiene complejidad polinomial. 

---
### Maquina de Turing

Se especifica una maquina de Turing que implementa la reduccion de la siguiente forma: 

1. Recibe una formula CNF codificada como entrada. 
2. Recorre la cinta para identificar las variables y las clausulas. 
3. Construye sobre la cinta una codificacion de la instancia correspondiente del problema `B`, incluyendo estaciones, transiciones, restricciones y cota de costo. 
4. La construccion se realiza en tiempo polinomial respecto al tamaño de la entrada. 
5. La maquina se detiene dejando en la cinta la instancia codificada de `B`. 
---
### Ejemplo de ejecucion de la Maquina de Turing

Sea la formula:

`φ = (x1 ∨ ¬x2)` 

Su codificacion en la cinta es:

`p1#n11` 

#### Cinta inicial

... ␣ ␣ p 1 # n 1 1 ␣ ␣ ...
        ↑
#### Cinta final


␣ ␣ V:x1,x2 | E:[transiciones] | w:[costos] | P:[precedencias] | X:[exclusiones] | k:10 ␣ ␣
                                                        

el cabezal estaria al final de esta parte de la cinta

---
## 2.2 Teorema de Cook-Levin

El teorema de Cook-Levin establece que el problema SAT es NP-completo.

Esto significa que:

- SAT pertenece a la clase NP.
- Todo problema en NP puede reducirse en tiempo polinomial a SAT.

Este resultado es fundamental en teoría de la complejidad, ya que demuestra la existencia de problemas NP-completos y permite clasificar la dificultad de otros problemas mediante reducciones.

---

### Prueba 1: Codificación de la Máquina de Turing

La primera demostración se basa en el modelo de Máquina de Turing.

Sea un lenguaje L ∈ NP. Por definición, existe una máquina de Turing no determinística M que decide L en tiempo polinomial.

La idea de la prueba es construir, para cada instancia x, una fórmula booleana φ tal que:

x ∈ L ⇔ φ es satisfacible.

Para ello:

- Se codifica la ejecución de la máquina M sobre la entrada x.
- Se representa la cinta de la máquina como una tabla con filas (tiempo) y columnas (posiciones de la cinta).
- Se introducen variables booleanas que representan:
  - el símbolo en cada posición,
  - el estado de la máquina,
  - la posición del cabezal.

Luego se construyen cláusulas que garantizan:

- que la configuración inicial es correcta,
- que cada paso sigue las reglas de transición de la máquina,
- que se alcanza un estado de aceptación.

La fórmula resultante es satisfacible si y solo si existe una ejecución válida de la máquina que acepta x.

Dado que la construcción se realiza en tiempo polinomial, se concluye que:

L ≤p SAT.

---

### Prueba 2: Verificadores y certificados

Otra forma de demostrar el teorema se basa en la definición de NP mediante verificadores.

Sea un lenguaje L ∈ NP. Entonces existe un verificador V que, dado un input x y un certificado y de tamaño polinomial, decide en tiempo polinomial si x pertenece a L.

La idea es construir una fórmula booleana que simule la ejecución del verificador:

- Se codifican las variables de entrada x y del certificado y.
- Se representan los estados intermedios de la computación del verificador.
- Se construyen cláusulas que expresan las operaciones del verificador paso a paso.

La fórmula resultante es satisfacible si y solo si existe algún certificado y tal que V(x, y) acepta.

Por lo tanto:

x ∈ L ⇔ φ es satisfacible

y la transformación se realiza en tiempo polinomial.

---

### Conclusión

Ambas demostraciones establecen que cualquier problema en NP puede reducirse a SAT en tiempo polinomial.

Dado además que SAT ∈ NP, se concluye que SAT es NP-completo.

---
## 2.3 NP-completitud del problema B

Se demuestra que el problema B (Planificación cíclica con restricciones) es NP-completo.

### B pertenece a NP

El problema B pertenece a la clase NP, ya que dada una instancia y una solución candidata (una secuencia de estaciones), es posible verificar en tiempo polinomial si dicha solución es válida.

En la Parte 1 se implementó la función `verifyB`, que verifica:

- cobertura total,
- consistencia de transiciones,
- restricciones de precedencia,
- exclusiones locales,
- cota de costo.

Todas estas verificaciones se realizan en tiempo polinomial, por lo que B ∈ NP.

---

### Reducción desde SAT

En la sección 2.1 se definió una reducción polinomial:

SAT ≤p B

donde cada fórmula booleana se transforma en una instancia del problema de planificación, preservando satisfacibilidad.

---

### Conclusión

Dado que:

- SAT es NP-completo,
- SAT ≤p B,
- B ∈ NP,

se concluye que el problema B es NP-completo.
