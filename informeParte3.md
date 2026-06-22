# Trabajo Final - Teoria de la Computacion

## 1. Verificador de SAT en Imp

Se implemento un verificador de SAT en el lenguaje Imp.  
El programa recibe una formula en forma normal conjuntiva (CNF) y una interpretacion, y determina si la formula es satisfecha por dicha interpretacion.

### Estrategia

El algoritmo funciona de la siguiente manera:

- Se recorren todas las clausulas de la formula.
- Para cada clausula, se verifican todos sus literales.
- Una clausula es verdadera si al menos uno de sus literales es verdadero.
- La formula completa es verdadera si todas las clausulas son verdaderas.

Esto corresponde a aplicar:

- OR en cada clausula
- AND entre clausulas

La implementacion en Imp sigue exactamente este esquema utilizando estructuras `Whiles` y `Cases`.

---

### Complejidad

Sea:
- m = cantidad de clausulas
- k = cantidad de literales por clausula
- n = cantidad de variables en la interpretacion

La complejidad es:

O(m * k * n)

ya que:
- cada clausula recorre sus literales
- cada literal puede requerir buscar en la interpretacion

Por lo tanto, el algoritmo es polinomial.

---

## 2. Codificacion de B en Maquina de Turing

En este trabajo se define:

- B = SAT
- DomB = conjunto de formulas en CNF

---

### Alfabeto

Se define el alfabeto:

Σ = {0, 1, p, n, #, ;}

donde:

- "1" representa el sucesor (numeros naturales)
- "0" representa el valor cero
- "p" representa un literal positivo
- "n" representa un literal negativo
- "#" separa literales dentro de una clausula
- ";" separa clausulas

---

### Codificacion

#### Variables

Las variables se codifican como cantidad de unos, como vimos en clase la representacion de naturales en MT:

x1 -> 1  
x2 -> 11  
x3 -> 111  

---

#### Literales

Pos(x2) -> p11  
Neg(x3) -> n111  

---

#### Clausula

Los literales se separan con `#`:

p1#n11#p111

---

#### Formula CNF

Las clausulas se separan con `;`:

p1#n11#p111 ; n1#p11#p111 ; p11#p111

---

### Maquina de Turing

Se define una Maquina de Turing M que decide SAT de la siguiente forma:

1. La maquina recibe una formula codificada en la cinta.
2. Recorre la entrada e identifica las variables.
3. Genera no deterministicamente una interpretacion (asignacion de valores booleanos).
4. Para cada clausula:
   - verifica si al menos un literal es verdadero
   - si no existe ninguno verdadero, rechaza
5. Si todas las clausulas son verdaderas, la maquina acepta.

---
## 2.1 Codificacion de la reduccion en Maquina de Turing

En la primera parte del trabajo se definieron los problemas:

- A = SAT
- B = Planificacion ciclica con restricciones

El objetivo es definir una reduccion polinomial:

SAT ≤p B

---

### Idea de la reduccion

Dada una formula booleana φ en CNF, se construye una instancia del problema de planificacion de la siguiente forma:

- Cada variable de φ se representa como una estacion.
- Para cada variable, se crean dos posibles decisiones (True / False).
- Las clausulas se representan mediante restricciones que aseguran que al menos una de las decisiones asociadas a sus literales sea satisfecha.
- Se agregan restricciones de precedencia y exclusiones para modelar los literales positivos y negados.
- El grafo de transiciones se construye de forma que solo recorridos validos correspondan a interpretaciones consistentes.

---

### Correccion

Si φ es satisfacible, entonces existe una asignacion de valores de verdad a sus variables que satisface todas sus clausulas.

A partir de esta asignacion, se puede construir una secuencia ciclica de estaciones que respeta todas las restricciones del problema B.

Por otro lado, si no existe una asignacion que satisfaga φ, entonces no es posible construir una secuencia valida que cumpla todas las restricciones del problema B.

Por lo tanto, la reduccion preserva satisfacibilidad.

---

### Complejidad

La construccion de la instancia del problema B a partir de φ implica recorrer las variables y clausulas una cantidad polinomial de veces.

Por lo tanto, la reduccion tiene complejidad polinomial.

---

### Maquina de Turing

Se define una maquina de Turing que implementa esta reduccion de la siguiente forma:

1. Recibe una formula CNF codificada.
2. Recorre la entrada para identificar variables y clausulas.
3. Construye una nueva representacion en la cinta correspondiente a la instancia del problema B.
4. La construccion se realiza en tiempo acotado por un polinomio en el tamaño de la entrada.
5. La maquina se detiene dejando en la cinta la instancia codificada de B.

De esta forma, la maquina transforma instancias de SAT en instancias equivalentes del problema de planificacion.

### Ejemplo de ejecución de la Máquina de Turing

Sea la fórmula:

φ = (x1 ∨ ¬x2)

Su codificación en la cinta es:

p1#n11

La cinta inicial es:

... p 1 # n 1 1  ...

El cabezal comienza sobre el primer símbolo

---

La máquina transforma esta fórmula en una instancia del problema B.

Se construyen los siguientes componentes:

- V = {x1, x2}
- E = posibles decisiones de valores (True/False)
- P = ∅
- X = {(x1_false, x2_true)}
- k = constante suficientemente grande

---

La instancia se codifica en la cinta como:

V x1,x2 | E x1x1t,x1x1f,x2x2t,x2x2f | P | X x1f x2t | k 10

---

La cinta final es:

... V x1,x2 | E x1x1t,x1x1f,x2x2t,x2x2f | P | X x1f x2t | k 10 ...

El cabezal se detiene en un estado de parada sobre la salida.
