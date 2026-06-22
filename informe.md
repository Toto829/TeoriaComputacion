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
