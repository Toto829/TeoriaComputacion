{-# LANGUAGE DeriveGeneric, DeriveAnyClass #-}
module Obl2 where
import Data.List (nub)

import Criterion.Main
import Control.DeepSeq (NFData)
import GHC.Generics (Generic)
import Obl (notChi)

-- Import necesario para evitar errores de print por parte de Criterion 
--import System.IO (stdout, hSetEncoding, utf8)

-- ==========================================================
--  Ejercicio 1
-- ==========================================================

data Exp = Var X
        | Abs X Exp
        | App Exp Exp
        | Let X Exp Exp
        deriving (Show, Eq, Generic, NFData)

type X = String
type Mem = [(X,Exp)]

-- ==========================================================
--  Ejercicio 2
-- ==========================================================

fv :: Exp -> [String]
fv (Var v) = [v] 
fv (Abs v e) = sacarElem v (fv e)
fv (App e1 e2) = nub (fv e1 ++ fv e2)

sacarElem :: String -> [String] -> [String]
sacarElem v [] = []
sacarElem v (x:xs)
    | v==x = xs
    | otherwise = x:(sacarElem v xs)

-- ==========================================================
--  Ejercicio 3
-- ==========================================================

pertenece :: String -> Exp -> Bool
pertenece x (Var v) 
    | x == v = True
    | otherwise = False
pertenece x (Abs v t)
    | x == v = False
    | otherwise = pertenece x t
pertenece x (App e1 e2) = (pertenece x e1) || (pertenece x e2)
pertenece x (Let y n e) = (pertenece x e)

darVarNueva :: [X] -> X
darVarNueva lv = buscarVariable 0
    where 
        buscarVariable i
            | elem nombre lv = buscarVariable (i+1)
            | otherwise = nombre
            where
                nombre = "a" ++ show i

subst :: String -> Exp -> Exp -> Exp
subst x  n (Var v)
    | x == v = n
    | otherwise = (Var v)
    
subst x n (App e1 e2) = App (subst x n e1) (subst x n e2)

subst x n (Abs v t)
    | x == v = (Abs v t)
    | pertenece v n = let z = darVarNueva ((fv t) ++ (fv n) ++ [x])
                          t' = (subst v (Var z) t)
                      in (Abs z (subst x n t'))
    | otherwise = Abs v (subst x n t)

subst x n (Let v e1 e2)
    | x == v = Let v (subst x n e1) e2
    | pertenece v n =  let z = darVarNueva ((fv e1) ++ (fv n) ++ (fv e2) ++[x])
                           e2' = (subst v (Var z) e2)
                      in (Let z (subst x n e1) (subst x n e2'))
    | otherwise = Let v (subst x n e1) (subst x n e2)

-- ==========================================================
--  Ejercicio 4
-- ==========================================================

esValor :: Exp -> Bool
esValor (Abs _ _) = True
esValor (Var _)   = True
esValor _ = False 

step :: Exp -> Maybe Exp
step (Var x) = Nothing
-- Lo ideal es retornar Nothing en el paso, dado que estrictamente hablando es un valor
step (Abs x e) = Nothing
step (App (Abs x e1) e2)
   | esValor e2 = Just (subst x e2 e1) 
step (App e1 e2)
    | not (esValor e1) = do 
            e1' <- step e1
            return (App e1' e2)

    | not (esValor e2) = do
            e2' <- step e2
            return (App e1 e2')
    | otherwise = Nothing
step (Let x e1 e2)
    | not (esValor e1) = do
            e1' <- step e1
            return (Let x e1' e2)
    | otherwise = Just (subst x e1 e2)

-- ==========================================================
--  Ejercicio 5
-- ==========================================================

eval :: Exp -> Exp
eval e = case step e of
    Just e' -> eval e'
    Nothing
        | esValor e -> e
        | otherwise -> error "Expresion no valida"

-- ==========================================================
--  Ejercicio 6
-- ==========================================================

pretty :: Exp -> String
pretty (Var x) = x
pretty (Abs x e) = "\\" ++ x  ++ ". " ++ pretty e
pretty (Let x e1 e2) = "let " ++ x ++ " = " ++ pretty e1 ++ " in " ++ pretty e2
pretty (App e1 e2) = prettyIzq e1 ++ " " ++ prettyDer e2

prettyDer :: Exp -> String
prettyDer e@(App _ _) = "(" ++ pretty e ++ ")"
prettyDer e@(Abs _ _) = "(" ++ pretty e ++ ")"
prettyDer e@(Let _ _ _) = "(" ++ pretty e ++ ")"
prettyDer e = pretty e

prettyIzq :: Exp -> String 
prettyIzq e@(Abs _ _) = "(" ++ pretty e ++ ")"
prettyIzq e@(Let _ _ _) = "(" ++ pretty e ++ ")"
prettyIzq e = pretty e

-- ==========================================================
--  Ejercicio 7
-- ==========================================================

-- Se evaluaron 3 tipos de implementaciones posibles para implementar el sharing

-- Primero se planteo la posbilidad de utilizar un Heap, que represente una lista de duplas. 
-- La primera representando una direccion de memoria y la segunda la espresion a ser sustituida. 
-- Esta implementacion segun la IA es la mas alineada con como funciona los motores reales de evaluacion, a la vez que mantiene cierta pureza alogritmica al uno poder auditar todo el proceso de busqueda.
-- Como puntos en contra de esta implementacion es que modifica todas las firmas de las funciones al ser necesario enviar en cada paso la memoria en Heap, esto a su vez puede generar lentitud en programas de gran magnitud al tener que leer la memoria para cada sustitucion.
-- Por más que de forma teorica esto sería O(1) dado que representa una RAM

-- Como segunda implementación, se evaluo utilizar el Arbol de Sintaxis Abstracta como memoria.
-- Ampliando el lenguaje y agregando la expresion Let String Exp Exp, esto permite evitar ensuciar las firmas de las funciones yua existentes, unicamente siendo necesario ampliar la cobertura para que prevean el caso de let.
-- Esta es una buena opcion dado que no depende de factores globales ni conceptos nuevos, utiliza las logicas ya existentes, siendo llamada por la inteligencia artificial como una "solución algebraica perfecta". 
-- A su vez, al realizar los analisis con steps, permite tener una lectura clara de los pasos que sigue el sharing de forma local.
-- Algunos puntos en contra de esta implementación son que sobrecarga la substitución, generando todo el peso de trabajo sobre la misma al tener que evaluar los casos de shadowing y de renombramiento.
-- La otra desventaja que presenta es que el acceso a la "memoria" es unicamente heredado hacia abajo en el arbol de procesamiento

-- La ultima implementación sugerida es una Memoria Mutable, utilizando mónadas de IO o ST.
-- Esto se trata de forma directa la RAM por medio de referencias mutables inherentes de Haskell.
-- Sus mayores ventajas son su rápida lectura, sharing instantaneo e invisible, en cada evaluacion de Thunk se benefician todos los involucrados de forma directa, mutando el resultado de todos.
-- Facilita la recursión infinita en memoria al utilizar herramientas nativas de Haskell.
-- Si bien presenta numerosas ventajas, sus mayores desventajas son que "ensucia" todas las firmas de las funciones, al tener que indicar que la salida es de tipo IO, presentan muchis parametros ocultos, complejizando e testeo y analisis del proceso. 
-- Por último también dificulta mucho el realizar los show y el pertty dado que debe de hacer todas las busquedas en memoria antes para poder desreferenciar todos los punteros manualmente.

--Ante estas tres opciones, el equipo opto por utilizar el Let. 
-- Esta decisión se tomó buscando la solución más alineada con el curso, en lo que respecta a no utilizar tipo de datos que no esten dentro del Preludio.
-- Otro punto que nos llevo a esta decisión es que nos pareció más rapida de implementar y menos compleja que las demas propuesta.
-- Siendo estas las razones por las que optamos por el modelado utilizando Let.

-- ==========================================================
--  Ejercicio 8
-- ==========================================================

-- ==========================================================
--  Calculo Lambda Puro
-- ==========================================================

-- Cero
-- \s.\x. x

-- Uno
-- \s.\x. s x

-- Dos
-- \s. \x. s (s x)

-- Sucesor
-- \n. \s. \x. s ( n s x )

-- Suma
-- \n. \m. \s. \x. n s (m s x)

-- Multiplicacion
-- \n. \m. \s. \x. n (m s) x)

-- ==========================================================
--  Calculo Lambda Embebido
-- ==========================================================

cero :: Exp
cero = Abs "s" (Abs "x" (Var "x"))


uno :: Exp
uno = Abs "s" (Abs "x" (App (Var "s") (Var "x")))


dos :: Exp
dos = Abs "s" (Abs "x" (App (Var "s") (App (Var "s") (Var "x"))))

sucesor :: Exp
sucesor =  Abs "n" (
        Abs "s" (
            Abs "x"(
                App 
                (Var "s") 
                (App 
                    (App (Var "n") (Var "s")) 
                    (Var "x")
                )
            )
        )
    )

suma :: Exp
suma = Abs "n" (
        Abs "m" (
            Abs "s" (
                Abs "x"(
                    App 
                    (App 
                        (Var "n")
                        (Var "s")
                    )
                    (App 
                        (App (Var "m") (Var "s")) 
                        (Var "x")
                    )
                )
            )
        )
    )

mult :: Exp
mult = Abs "n" (
        Abs "m" (
            Abs "s" (
                Abs "x"(
                    App 
                    (App 
                        (Var "n")
                        (App 
                            (Var "m") 
                            (Var "s")
                        )
                    )
                    (Var "x")
                )
            )
        )
    )

-- ==========================================================
--  Evaluador con Call-by-Name - Generados por IA
-- ==========================================================

--Implementado para ver de mejor manera los ejemplos

stepName :: Exp -> Maybe Exp
stepName (Var x) = Nothing
stepName (Abs x e) = do
    e' <- stepName e
    return (Abs x e')
stepName (App (Abs x e1) e2) = Just (subst x e2 e1)
stepName (App e1 e2)
    | not (esValor e1) = do 
            e1' <- stepName e1
            return (App e1' e2)

    | not (esValor e2) = do
            e2' <- stepName e2
            return (App e1 e2')
    | otherwise = Nothing
stepName (Let x e1 e2)
    | not (esValor e1) = do
            e1' <- stepName e1
            return (Let x e1' e2)
    | otherwise = Just (subst x e1 e2)


evalName :: Exp -> Exp
evalName e = case stepName e of
    Just e' -> evalName e'
    Nothing
        | esValor e -> e
        | otherwise -> error "Expresion no valida"

-- ==========================================================
--  Casos de prueba - Generados por IA
-- ==========================================================

ejemploSucesor :: Exp
ejemploSucesor = App sucesor uno

ejemploSuma :: Exp
ejemploSuma = App (App suma uno) dos

ejemploMult :: Exp
ejemploMult = App (App mult dos) dos

ejemploFusion :: Exp
ejemploFusion = 
    App 
        (App mult (App (App suma uno) dos))  
        
        (App sucesor dos)

-- ==========================================================
--  Ejercicio 9
-- ==========================================================

-- =====================================================================================
--  Calculo Lambda Sin Sharing - Reescrito con IA porque ya se habia hecho anteriormente
-- =====================================================================================

type XSin = String

data ExpSin = VarSin XSin
            | AbsSin XSin ExpSin
            | AppSin ExpSin ExpSin
            deriving (Show, Eq, Generic, NFData)

esValSin :: ExpSin -> Bool
esValSin (AbsSin _ _) = True
esValSin _            = False

fvSin :: ExpSin -> [XSin]
fvSin (VarSin v)     = [v]
fvSin (AbsSin v e)   = sacarElem v (fvSin e)
fvSin (AppSin e1 e2) = nub (fvSin e1 ++ fvSin e2)

nuevaVarSin :: [XSin] -> XSin
nuevaVarSin usedVars = buscarVariable 0
  where 
    buscarVariable i
      | nombre `elem` usedVars = buscarVariable (i + 1)
      | otherwise              = nombre
      where nombre = "v" ++ show i


substSin :: XSin -> ExpSin -> ExpSin -> ExpSin
substSin x n (VarSin v)
    | x == v    = n
    | otherwise = VarSin v
substSin x n (AppSin e1 e2) = AppSin (substSin x n e1) (substSin x n e2)
substSin x n (AbsSin v t)
    | x == v = AbsSin v t
    | v `elem` fvSin n = 
        let z = nuevaVarSin (fvSin t ++ fvSin n ++ [x])
            tAlpha = substSin v (VarSin z) t
        in AbsSin z (substSin x n tAlpha)
    | otherwise = AbsSin v (substSin x n t)


stepSin :: ExpSin -> Maybe ExpSin
stepSin (AppSin (AbsSin x e1) e2) 
    | esValSin e2 = Just (substSin x e2 e1)
stepSin (AppSin e1 e2) 
    | not (esValSin e1) = do
        e1' <- stepSin e1
        return (AppSin e1' e2)
stepSin (AppSin e1 e2) = do
    e2' <- stepSin e2
    return (AppSin e1 e2')
stepSin _ = Nothing


evalSin :: ExpSin -> ExpSin
evalSin e = case stepSin e of
    Just e' -> evalSin e'
    Nothing 
        | esValSin e -> e
        | otherwise  -> error "Expresión atascada en evaluador Sin Sharing"

-- ==========================================================
--  Generación de Pruebas
-- ==========================================================

-- Yunque 

crearChurchSin :: Integer -> ExpSin
crearChurchSin n = AbsSin "s" (AbsSin "z" (aplicarNSin n (VarSin "s") (VarSin "z")))
  where
    aplicarNSin 0 _ base = base
    aplicarNSin i f base = AppSin f (aplicarNSin (i - 1) f base)

crearChurch :: Integer -> Exp
crearChurch n = Abs "s" (Abs "z" (aplicarN n (Var "s") (Var "z")))
  where
    aplicarN 0 _ base = base
    aplicarN i f base = App f (aplicarN (i - 1) f base)

-- Trampa

crearTrampaSin :: Integer -> ExpSin
crearTrampaSin n = 
    AppSin 
        (AbsSin "x" (AppSin (VarSin "x") (AppSin (VarSin "x") (VarSin "x")))) 
        (crearChurchSin n)

crearTrampa :: Integer -> Exp
crearTrampa n = 
    App 
        (Abs "x" (App (Var "x") (App (Var "x") (Var "x")))) 
        (crearChurch n)


-- =========================================================================
-- 4. CRITERION (Motor de pruebas) - Generado por IA
-- =========================================================================
--Ejecutar con
-- ghc -O2 -package deepseq -package criterion -main-is Obl2 obl2.hs
-- ./obl2.exe --output resultados.html

-- Ejemplo de simplemente evaluacion numerica
-- main :: IO ()
-- main = do
--     hSetEncoding stdout utf8
--     defaultMain
--         [ 
--             bgroup "Tamanio N = 25"
--             [ bench "Implementacion SIN Sharing" $ nf evalSin (crearTrampaSin 25)
--             , bench "Implementacion CON Sharing" $ nf eval (crearTrampa 25)
--             ]
            
--         , bgroup "Tamanio N = 60"
--             [ bench "Implementacion SIN Sharing" $ nf evalSin (crearTrampaSin 60)
--             , bench "Implementacion CON Sharing" $ nf eval (crearTrampa 60)
--             ]
            
--         , bgroup "Tamanio N = 100"
--             [ bench "Implementacion SIN Sharing" $ nf evalSin (crearTrampaSin 100)
--             , bench "Implementacion CON Sharing" $ nf eval (crearTrampa 100)
--             ]
--         ]

-- Se observa que en valores grandes de N en el que no hay computo, se comportan similares ambas implementaciones, ahora se cambiara la "Trampa"
-- para que asi si requiera computo y se observe de mejor manera la ventaja temporal de utilizar sharing sobre no utilizarlo.
-- Con valores de N comprendidos entre 1 y 15 se logra ambien observar una gran ventaja de sharing sobre su contraparte.

sucesorSin :: ExpSin
sucesorSin =  AbsSin "n" (
        AbsSin "s" (
            AbsSin "x"(
                AppSin 
                (VarSin "s") 
                (AppSin 
                    (AppSin (VarSin "n") (VarSin "s")) 
                    (VarSin "x")
                )
            )
        )
    )

-- Nueva trampa: (\x. x x x) (SUCC ChurchN)
-- Nota que (App sucesor ChurchN) NO es un valor, es un cómputo pendiente.

crearTrampaComputacionSin :: Integer -> ExpSin
crearTrampaComputacionSin n = 
    AppSin 
        (AbsSin "x" (AppSin (VarSin "x") (AppSin (VarSin "x") (VarSin "x")))) 
        (AppSin sucesorSin (crearChurchSin n))

crearTrampaComputacion :: Integer -> Exp
crearTrampaComputacion n = 
    App 
        (Abs "x" (App (Var "x") (App (Var "x") (Var "x")))) 
        (App sucesor (crearChurch n))

-- main :: IO ()
-- main = do
--     hSetEncoding stdout utf8
--     defaultMain
--         [ 
--             bgroup "Tamanio N = 25"
--             [ bench "Implementacion SIN Sharing" $ nf evalSin (crearTrampaComputacionSin 25)
--             , bench "Implementacion CON Sharing" $ nf eval (crearTrampaComputacion 25)
--             ]
            
--         , bgroup "Tamanio N = 60"
--             [ bench "Implementacion SIN Sharing" $ nf evalSin (crearTrampaComputacionSin 60)
--             , bench "Implementacion CON Sharing" $ nf eval (crearTrampaComputacion 60)
--             ]
            
--         , bgroup "Tamanio N = 100"
--             [ bench "Implementacion SIN Sharing" $ nf evalSin (crearTrampaComputacionSin 100)
--             , bench "Implementacion CON Sharing" $ nf eval (crearTrampaComputacion 100)
--             ]
--         ]

-- En caso que se requiera computo, se observa que con Sharing es aproximadamente 3 veces más rapido que una implementación sin Sharing
-- Esto demuestra una gran diferencia a nivel computacional, demostrando asi la gran superioridad del sharing

-- ==========================================================
--  Ejercicio 10
-- ==========================================================

-- Indices De Bruijn,

-- Los indices de Bruijn son una forma de buscar representar las variables en calculo Lambda, sin necesidad de utilizar nombres concretos
-- En su lugar se intercambian por valores numericos, que hacen referencia a que abstracción están ligadas las variables.
-- Estos valores hacen referencia a la distancia que se encuentra la variable de lo que estos dependen. 
-- Un ejemplo, es  \x.x, utilizando indices de De Bruijn quedaria \.0
-- No sería necesario declarar el nombre de la variable, puesto que ya se indica en el numero, y sabemos que hace referencia al dicha abstracción
-- dado que es la única que se encuentra a 0 saltos de distancia
-- Otros ejemplos son \x.x x, que en notación sería \.0 0
-- Y \x. \y. x y, sería \. \. 1 0 

-- Este metodo es de suma importancia, dado que evita una de las mayores complicaciones del calculo lambda y de varios lenguajes que son las substituciones
-- Logrando así evitar problemas con darle nombre a variables libres y variables ligadas, quitando todo problema inherente a las mismas y superposición de nombres.
-- A su vez, logra realizar computos de forma mucho más rápida, dado que es más simple para el compilador comparar dos variables como integer que como strings
-- Esto facilita la lectura de maquina, y evita complejizar innecesariamente, cosa que el compilador necesite emplear más calculos

-- Las principales ventajas son que es dos funciones una que utiliza De Bruijn y otro que usa nombres, se compila de la misma forma. 
-- Tan solo que comprar int es mucho más simple que integer.
-- Otra gran ventaja de este modelo es que no requiere calculo para buscar nombres de variables nuevas para evitar conflictos entre variables libres y ligadas.
-- Por último, este método es mucho más rápido en operaciones, no solo por simplesa de comparación numérica, sino también en el manejo de memoria
-- Utilizar variables numericas simplifica también la escritura y lectura en disco y memoria, haciendo que sea mucho más veloz este metodo que uno con variables

-- Comenzando las desventajas, tenemos como primera la lectura humana. Al estar carente de toda 'candy syntaxis', es ultra complejo para el ser humano distinguir
-- a que variables se están haciendo referencia en cada instancia. Dificultando mucho la comprensión al no ser nada clara para una persona.
-- Luego, la mayor desventaja a nivel computacional, es que luego de cada substitucion en el codigo se debe hacer un desplazamiento de todo los nomrbes de las variables
-- debido a que sus posiciones relativas se vio alterada al "perder" una abstracción.
-- 
-- Algunos ejemplos:
-- El valor de la variable representa la distancia en abstracciones de la variable de la que dependen 
--  
-- Ejemplo A - Identidad
-- \x.x
-- \.0
-- Nota: Es 0 ya que estan al mismo nivel

-- Ejemplo B - Ignora el primer argumento - False
-- \x.\y.y
-- \.\.0

-- Ejemplo C - Ignora el segundo argumento - True
-- \x.\y.x
-- \.\.1
-- Nota: Es 1, dado que la primer lambda no corresponde a x, es la siguiente, entonces debe "saltar" uno

-- Ejemplo D - Aplicacion interna
-- \x.(\y.x y)
-- \.(\. 1 0)

-- Ejemplo E - Aplicacion a uno mismo
-- \x. x x
-- \. 0 0
