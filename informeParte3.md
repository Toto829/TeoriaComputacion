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
## 1.2 Codificacion de B en Maquina de Turing

En la primera parte del trabajo se definio el problema `B = Planificacion ciclica de tareas con restricciones`, cuya instancia tiene la forma:

`I = (V, E, w, P, X, k)`

donde:
- `V` es el conjunto de estaciones,
- `E` es el conjunto de transiciones permitidas,
- `w` asigna un costo a cada transicion,
- `P` es el conjunto de restricciones de precedencia,
- `X` es el conjunto de exclusiones locales,
- `k` es una cota maxima de costo. 【2-6d2962】

### Alfabeto

Se define un alfabeto suficiente para codificar todos los componentes de una instancia de `B`:

`Σ_B = {0,1,V,E,W,P,X,K,(,),,,;,#}`

donde:
- `0` y `1` se usan para codificar identificadores y costos,
- `V,E,W,P,X,K` identifican cada componente de la instancia,
- `(`, `)`, `,`, `;`, `#` se usan como separadores.

### Codificacion

Una instancia `I = (V,E,w,P,X,k)` se codifica como una cadena de la forma:

`V#cod(V);E#cod(E);W#cod(w);P#cod(P);X#cod(X);K#cod(k)`

donde cada subconjunto o relacion se representa como una lista separada por `;`, y cada elemento individual se representa usando identificadores de estaciones codificados en binario o unario (palitos como en clase o binario).

Por ejemplo, una instancia simple puede quedar representada como:

`V#1;10;11;E#(1,10);(10,11);W#((1,10),1);((10,11),1);P#;X#;K#11`

### Maquina de Turing

Se especifica una Maquina de Turing no determinista que resuelve `B` de la siguiente forma:

1. Recibe una instancia `I = (V,E,w,P,X,k)` codificada en la cinta.
2. Genera no deterministicamente una secuencia candidata de estaciones.
3. Verifica que la secuencia:
   - cubra todas las estaciones exactamente una vez,
   - use solo transiciones de `E`,
   - respete las restricciones de precedencia `P`,
   - respete las exclusiones `X`,
   - y tenga costo total menor o igual que `k`.
4. Si todas las condiciones se cumplen, acepta. En caso contrario, rechaza.

Como la verificacion de una secuencia candidata puede hacerse en tiempo polinomial, se concluye que `B` pertenece a NP.

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
  
Con cabezal en el primer elemento

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

---

### 2.4 Analisis del codigo generado por IA

El codigo generado por IA nos parece bastante acertado: representar cada literal de cada clausula como una tarea y agregar restricciones para capturar incompatibilidades entre elecciones. En ese sentido, la funcion `conflicto` reconoce correctamente la oposicion entre un literal positivo y uno negativo sobre la misma variable.

Sin embargo, el resultado no constituye una implementacion correcta de la reduccion pedida. El motivo principal es que no construye una instancia del problema `B` tal como fue definido en la Parte 1, es decir, una estructura de la forma `(V,E,w,P,X,k)`. En lugar de eso, devuelve un par `([Tarea], [Restriccion])`, que corresponde a otro problema de restricciones.

Ademas, la funcion `restriccionesClausulas` impone incompatibilidades entre literales de una misma clausula, lo cual no coincide con SAT. En una clausula pueden ser verdaderos varios literales al mismo tiempo, solo se requiere que al menos uno lo sea. Por eso, la construccion no preserva correctamente la satisfacibilidad.

---