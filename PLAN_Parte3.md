# Plan para terminar la Tercera Parte — Teoría de la Computación

Estado a la fecha: 1.1 hecho (con bugs), 1.2 mal enfocado, 2.1 parcial, 2.3 esbozado, 2.4 con código IA roto.
Faltan: 1.2 sobre B, 2.2 (Cook-Levin), 2.4 análisis, 2.5, y los entregables `informe.pdf` y `articulo.pdf`.

Leyenda: [ ] pendiente · [~] parcial · [x] hecho

---

## FASE 0 — Arreglos de código (rápido, desbloquea todo)

Hoy `Parte3.hs` NO compila, así que `verifySAT` no se pudo testear.

- [ ] **Línea 326** (`evaluarClausula`): quitar el guion suelto `, -` → debe quedar `, evaluarLiteral`.
- [ ] **Línea 468:** `construirTareas :: ...` está indentada → llevar a la columna 1.
- [ ] **Línea 486:** `restriccionesConflictos :: ...` está indentada → llevar a la columna 1.
- [ ] **Bug `res`/`resIgual` en `verifySAT`:** `igualdadNat` escribe en `res` (líneas 155, 173, 176) pero `buscarEnInterp` lee `resIgual` (línea 230). Cambiar `igualdadNat` para que escriba en **`resIgual`**. Así se arregla la lectura de variable indefinida Y se evita pisar la salida final `res`.
- [ ] Conseguir `Lab2.hs` (no está en la carpeta) y **compilar** `Parte3.hs`.
- [ ] **Testear** `verifySAT`:
  - `correrVerifySAT ej1 interpEj1Ok` → `True`
  - `correrVerifySAT ej1 interpEj1No` → `False`
  - `correrVerifySAT ej2 interpEj2` → `False` (es insatisfacible: pide x1 y ¬x1)

Criterio de hecho: el archivo compila y los 3 tests dan lo esperado.

---

## FASE 1 — Unificar la reducción SAT ≤p B (el punto crítico)

Hoy hay **tres versiones distintas** de la reducción: informe 2.1 (estaciones t/f), informe 2.3 (referencia a 2.1) y código 2.4 (`Tarea` + `NoSimultaneo`). Hay que dejar **una sola**, correcta, y que el código devuelva un `DomB = (V,E,W,P,X,K)` real.

### Decisión a tomar
- [ ] Reducir desde **3-SAT** (recomendado: SAT general → 3-SAT es poly y simplifica los gadgets).
- [ ] Empezar con el **gadget clásico** (P = X = ∅) y, si querés, después usar P/X para simplificar.

### Estrategia recomendada
B contiene al **Ciclo Hamiltoniano dirigido (DHC)**: si tomás `P = ∅`, `X = ∅`, `w(e) = 1` para toda arista y `k = |V|`, entonces *"existe secuencia cíclica válida"* ⟺ *"existe ciclo hamiltoniano"*. Por lo tanto alcanza con la reducción conocida **3-SAT ≤p DHC** (Sipser, Teorema 7.46):

- Por cada variable `xi`: un **gadget "diamante"** (un camino que se puede recorrer izquierda→derecha = `xi` verdadera, o derecha→izquierda = `xi` falsa).
- Por cada cláusula `cj`: un **nodo**.
- Conectar el diamante de `xi` con el nodo de `cj` en el tramo correspondiente si `xi` aparece positiva (recorrido →) o negativa (←) en `cj`.
- Un ciclo hamiltoniano elige una dirección por diamante (= una asignación) y puede visitar el nodo de cada cláusula **solo si** algún literal la satisface.

### Tareas
- [ ] Escribir la reducción **formal** (construcción de V, E; justificar P=X=∅, w, k).
- [ ] Probar **correctitud ida y vuelta**: φ satisfacible ⟹ hay ciclo; hay ciclo ⟹ φ satisfacible.
- [ ] Justificar que la construcción es **polinomial** (nº de nodos/aristas acotado por polinomio en variables y cláusulas).
- [ ] Reescribir `reduceAToB :: DomA -> DomB` (2.4) para que **devuelva un `DomB` real** con esta construcción.
- [ ] Reemplazar el informe 2.1 para que describa **esta** reducción (o formalizar la de estaciones t/f, pero el gadget de Sipser es más seguro).

---

## FASE 2 — 1.2: Codificación de B en Turing (falta)

Ojo: tu 1.2 actual codifica **A (SAT)** — eso sirve para 2.1, pero la consigna 1.2 pide **B**.

- [ ] Definir Σ para `DomB`: símbolos para ids de estación (unario o binario), separadores de listas (V, E, W, P, X) y para k.
- [ ] Definir la **codificación** de `(V, E, w, P, X, k)` como cadena, con un **ejemplo concreto**.
- [ ] Especificar una **MT (no determinista)** que resuelve B:
  1. Fase adivinar: genera no determinísticamente una permutación de V (secuencia candidata).
  2. Fase verificar (determinista, como `verifyB`): cobertura total, transiciones **incluyendo el cierre del ciclo `vn→v1`**, precedencias, exclusiones, y cota de costo.
  3. Acepta si todo se cumple.
- [ ] Concluir `B ∈ NP` (cada verificación es polinomial).

---

## FASE 3 — 2.2: Teorema Cook-Levin (falta, dos pruebas)

- [ ] **Prueba 1 — Tableau / "ventanas" (Sipser, cap. 7.4):** dada `L ∈ NP` con NTM `M` que corre en `n^k`, construir una fórmula φ que describa un *tableau* de cómputo (configuraciones). Variables `x[i,j,s]`. Cláusulas de: celda (una sola por casilla), inicio (primera fila = config inicial), aceptación (aparece `q_accept`) y movimiento (toda ventana 2×3 es legal según δ). φ satisfacible ⟺ `M` acepta. Tamaño polinomial.
- [ ] **Prueba 2 — Vía circuitos (Arora–Barak):** toda computación polinomial se expresa como un **circuito booleano** de tamaño poly; CIRCUIT-SAT es NP-completo; luego **CIRCUIT-SAT ≤p 3-SAT** con la transformación de **Tseitin** (una cláusula por compuerta).
- [ ] Explicar **en qué difieren** (la 1 construye la fórmula directa desde la MT; la 2 pasa por circuitos + Tseitin) y por qué ambas demuestran lo mismo.
- [ ] Citar fuentes (Sipser; Arora–Barak) en formato **IEEE**.

---

## FASE 4 — 2.4 análisis + 2.5 ejemplos (falta)

- [ ] **2.4 análisis (sin IA):** redactar qué harías **igual** y qué **distinto** respecto del código que generó la IA. Punto fuerte para criticar: el código original devolvía `([Tarea],[Restriccion])`, que **no es un `DomB`** ni captura la satisfacibilidad. Mostrar con ejemplos si los resultados son correctos.
- [ ] Guardar el **link o captura del chat de IA** usado para 2.4 (obligatorio por la consigna) y citarlo.
- [ ] **2.5:** tomar las DOS instancias de la consigna y mostrar su instancia de B correspondiente:
  - Ej1 (satisfacible): `(x1 ∨ ¬x2 ∨ x3) ∧ (¬x1 ∨ x2 ∨ x3) ∧ (x2 ∨ x3)`
  - Ej2 (insatisfacible): `(x1) ∧ (x2 ∨ x3) ∧ (¬x1)`
- [ ] Calcular el **orden** de la construcción y argumentar que es polinomial.

---

## FASE 5 — Entregables (formato)

- [ ] **`solucion.hs`**: renombrar/consolidar `Parte3.hs` → `solucion.hs` con `verifySAT` corregido + `reduceAToB` (2.4) reescrito. Dejar ejemplos y comentarios.
- [ ] **`informe.pdf`**: pasar `informeParte3.md` a PDF, ya completo (1.1, 1.2 de B, 2.1, 2.2, 2.3, 2.4, 2.5), documentando todas las decisiones. Incluir links/capturas de IA.
- [ ] **`articulo.pdf`**: LaTeX, **template IEEE** (Overleaf), autocontenido, **solo** sobre B NP-completo:
  - B ∈ NP, la reducción 3-SAT ≤p B con el gadget, correctitud (ida y vuelta), complejidad polinomial. Pseudocódigo en vez de código completo.
- [ ] **Citas IEEE** de todas las fuentes externas.

---

## FASE 6 — Verificación final

- [ ] `solucion.hs` compila y pasan los tests.
- [ ] El **mismo modelo de B** aparece en código, informe y artículo (coherencia total).
- [ ] Revisar el **cierre del ciclo** en B (ver nota abajo).
- [ ] Defensa: poder explicar `verifySAT`, la reducción y las dos pruebas de Cook-Levin.

---

## Notas / riesgos

- **`verifyB` (Parte 1) no cierra el ciclo:** `verificarTransiciones` y `sumarCostos` no chequean `vn→v1` ni suman su costo (el comentario de `instancia1` espera 40 pero el código da 30). Como el artículo prueba que **B cíclico** es NP-completo, conviene que código y definición coincidan. Verificá / arreglá.
- **Regla de IA:** solo permitida para investigar conceptos y generar ejemplos. La **única** parte con código de IA es 2.4 (guardar el link). El informe, el artículo, la reducción y `verifySAT` deben ser **tuyos**.
- **Falta `Lab2.hs`** en la carpeta: necesario para compilar y testear `verifySAT`.
- **Cuello de botella:** Fases 1 y 3 (reducción correcta + Cook-Levin). Si esas salen bien, el resto es ensamblar.

---

## Preguntas para vos
1. ¿La entrega es grupal? ¿Quién toma el artículo en LaTeX?
2. ¿Confirmás que B es el problema **cíclico** (y arreglamos el cierre en `verifyB`)?
3. ¿Vamos con reducción desde **3-SAT** y gadget clásico (P=X=∅)?
