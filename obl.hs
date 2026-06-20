module Obl where
import Lab1

-- ==========================================================
--                         EJERCICIO 1
-- ==========================================================

-- ==========================================================
--                          PARTE 1.1
-- ==========================================================

-- ==========================================================
--  Implementacion A
-- ==========================================================

data Lit = Pos Var
         | Neg Var
         deriving (Show, Eq)

type Term = [Lit]
type Exp = [Term]
type Var = String
type Mem = [(Var,Bool)]

type DomA = Exp
type SolA = Maybe Mem

-- ==========================================================
--  Implementacion B
-- ==========================================================

type I = (V,E,W,P,X,K)

type Estacion = (String, Integer)
type V = [Estacion]
type E = [(Estacion,Estacion)]
type W = [((Estacion, Estacion), K)]
type P = [(Estacion,Estacion)]
type X = [(Estacion,Estacion)]
type K = Integer

type S = [Estacion]


type DomB = I
type SolB = Maybe S

-- ==========================================================
--                   PARTE 1.2
-- ==========================================================

-- ==========================================================
-- Verify A
-- ==========================================================

verifyA :: (DomA,SolA) -> Bool
verifyA (e, Just mem) = evalExp mem e
verifyA (_,Nothing) = False

obtenerValor :: Mem -> Var -> Bool
obtenerValor [] v = error "Memoria vacia o variable no encontrada"
obtenerValor ((vm,b):xs) v
    | vm == v = b
    | otherwise = obtenerValor xs v

evalLit :: Mem -> Lit -> Bool
evalLit m (Pos v) = obtenerValor m v
evalLit m (Neg v) = not (obtenerValor m v) 

evalTer :: Mem -> Term -> Bool
evalTer m [] = False
evalTer m (l:ls) = evalLit m l || evalTer m ls

evalExp :: Mem -> Exp -> Bool
evalExp m [] = True
evalExp m (t:xs) = evalTer m t && evalExp m xs

-- La funcion en eval evalua cada termino, luego evalua cada Literal de dicho termino, ahi tendriamos un n1 que equivale a los literales de dicho termino
-- Luego la funcion llama a obtenerValor que recore las V duplas(variable, booleano) en la memoria
-- Esto nos llevaria a un caso de O(n1*V) + o(n2*V) + ... + O(nn*V) = O((n1+...+nn)*V) = O(N*V), siendo N todos los literales de A 
-- Conclusion: Se verifica en O(N*V), N: Cantidad de literales, V: cantidad de duplas en memoria

-- ==========================================================
-- Verify B
-- ==========================================================

verifyB :: (DomB,SolB) -> Bool
verifyB (i,Just s) = esSecuenciaValida i s
verifyB (_, Nothing) = False

esSecuenciaValida :: I -> S -> Bool
esSecuenciaValida (v,e,w,p,x,k) s = 
    verificarCoberturaTotal v s &&
    verificarTransiciones e s &&
    verificarPrecedencias p s &&
    verificarExclusiones x s &&
    verificarCotas w k s 

-- El orden va a ser el maximo orden de todas las funciones llamadas

verificarCoberturaTotal :: V -> S -> Bool
verificarCoberturaTotal [] [] = True
verificarCoberturaTotal [] _ = False
verificarCoberturaTotal (v:vs) s
    | pertenece v s = verificarCoberturaTotal vs (borrarUnaVez v s)
    | otherwise = False

-- O(V*(N + N)) = recorre los v vertices, y recorre por cada vertice s para validar que este y eliminar
-- Suponiendo que son iguales V y N, es O(N^2) 

verificarTransiciones :: E -> S -> Bool 
verificarTransiciones [] s = True
verificarTransiciones e (s1:[]) = True  
verificarTransiciones e (s1:s2:ls) = encontrarTrans e (s1,s2) && verificarTransiciones e (s2:ls)

-- O(s*O(E))) y O(E) <= N^2, ya que es un par de Estaciones
-- Suponiendo que S y E sean similares a N, es O(N^3)

verificarPrecedencias :: P -> S -> Bool
verificarPrecedencias [] s = True
verificarPrecedencias (p:ps) (s:[]) = True
verificarPrecedencias (p:ps) s = cumplePrecedencia p s && verificarPrecedencias ps s

-- O(P*(S + S)), P es O(N^2) y S es O(N) => Es O(N^3)
-- Primer S es de noAparece y el segundo de Pertenece

verificarExclusiones :: X -> S -> Bool
verificarExclusiones _ [] = True
verificarExclusiones _ (s1:[]) = True
verificarExclusiones xs (s1:s2:ls) = 
    not (encontrarTrans xs (s1,s2)) && verificarExclusiones xs (s2:ls)

-- O (S * X) => O(N^3)

verificarCotas :: W -> K -> S -> Bool
verificarCotas w k s = (sumarCostos w s 0 <= k )

-- O(N * W), W <= N^2 => es O(N^3)
--En conclusion la verificacion se realiza en O(N^3)

-- Funciones Auxiliares 

cumplePrecedencia :: (Estacion, Estacion) -> S -> Bool
cumplePrecedencia _ [] = True 
cumplePrecedencia (u, v) (s:ls)
    | s == v = noAparece u ls
    | s == u = pertenece v ls
    | otherwise = cumplePrecedencia (u, v) ls

pertenece :: Estacion -> S -> Bool
pertenece _ [] = False
pertenece x (s:ls)
    | x == s = True
    | otherwise = pertenece x ls

borrarUnaVez :: Estacion -> S -> S
borrarUnaVez _ [] = []
borrarUnaVez e (s:ls)
    | e == s = ls
    | otherwise = s:(borrarUnaVez e ls)

sumarCostos :: W -> S -> Integer -> Integer
sumarCostos w [] k = k
sumarCostos w (s:[]) k = k
sumarCostos w (s1:s2:ls) k = let k' = k + darCostoTrans w (s1,s2)
                             in sumarCostos w (s2:ls) k'

darCostoTrans :: W -> (Estacion, Estacion) -> Integer
darCostoTrans [] _ = 0
darCostoTrans (((w1,w2),c):ws) (e1,e2) 
    | (w1 == e1) && (w2 == e2) = c
    | otherwise = darCostoTrans ws (e1,e2)

noAparece :: Estacion -> S -> Bool
noAparece e [] = True
noAparece e (s:ls)
    | e == s = False
    | otherwise = noAparece e ls

encontrarTrans :: [(Estacion,Estacion)] -> (Estacion,Estacion) -> Bool
encontrarTrans [] _ = False
encontrarTrans ((e1,e2):ls) (p1,p2)
    | (e1 == p1) && (e2 == p2) = True
    | otherwise = encontrarTrans ls (p1,p2)

-- ==========================================================
--                   PARTE 1.3
-- ==========================================================

-- ==========================================================
-- Solver A
-- ==========================================================

insertarSinRepe :: Mem -> Var -> Mem
insertarSinRepe [] v = [(v, False)] 
insertarSinRepe ((vm,b):ls) x
    | x == vm = (vm,b):ls
    | otherwise = (vm,b) : insertarSinRepe ls x

cargarLit :: Mem -> Lit -> Mem
cargarLit m (Pos c) = insertarSinRepe m c
cargarLit m (Neg c) = insertarSinRepe m c

cargarLitTerm :: Mem -> Term -> Mem
cargarLitTerm m [] = m
cargarLitTerm m (l:ls) = cargarLitTerm (cargarLit m l) ls 

cargarLitExp :: Mem -> Exp -> Mem
cargarLitExp m [] = m
cargarLitExp m (e:es) = cargarLitExp (cargarLitTerm m e) es

invertirSig :: Mem -> SolA
invertirSig [] = Nothing
invertirSig ((v,b):xs)
    | b = case invertirSig xs of
            Nothing -> Nothing 
            Just resto -> Just ((v, False) : resto)
    | otherwise = Just ((v, True) : xs)

evalSatis :: Mem -> Exp -> SolA
evalSatis m c 
    | evalExp m c = Just m
    | otherwise = case invertirSig m of
                    Nothing -> Nothing
                    Just mSiguiente -> evalSatis mSiguiente c

solveA :: DomA -> SolA
solveA c = let m = cargarLitExp [] c
                 in evalSatis m c

-- ==========================================================
-- Solver B
-- ==========================================================

solveB :: DomB -> SolB
solveB i@(v,_,_,_,_,_) = darSolucion i (permutaciones v)

darSolucion :: I -> [S] -> SolB
darSolucion i [] = Nothing
darSolucion i (s:ls)
    | esSecuenciaValida i s = Just s
    | otherwise = darSolucion i ls

--Algoritmo para generar una lista con todas las permutaciones posibles de la lista original

permutaciones :: V -> [S]
permutaciones [] = [[]]
permutaciones v = [ x:ys | (x, resto) <- selecciones v, ys <- permutaciones resto]

selecciones :: V -> [(Estacion, V)]
selecciones [] = []
selecciones (x:xs) = (x,xs) : [(y, x:ys) | (y,ys) <- selecciones xs]



-- ==========================================================
--                         PARTE 1.4
-- ==========================================================

-- ==========================================================
-- EJEMPLOS EJERCICIO A
-- ==========================================================

-- Ejemplo 1: Expresión satisfacible
ejemploSatisfacible :: Exp
ejemploSatisfacible = [ [Pos "A", Pos "B"]
                      , [Neg "A", Pos "C"]
                      , [Neg "B", Neg "C"] ]

-- Ejemplo 2: Expresión insatisfacible (Contradicción)
ejemploInsatisfacible :: Exp
ejemploInsatisfacible = [ [Pos "A"]
                        , [Neg "A"] ]

-- ==========================================================
-- CONSTANTES AUXILIARES EJERCICIO B
-- ==========================================================
eA :: Estacion
eA = ("A", 1)

eB :: Estacion
eB = ("B", 2)

eC :: Estacion
eC = ("C", 3)

eD :: Estacion
eD = ("D", 4)

-- ==========================================================
-- EJEMPLO 1: INSTANCIA EXITOSA (Debería devolver Just)
-- ==========================================================
-- El camino óptimo y válido aquí es: [eA, eB, eC, eD]
-- Al cerrarse el ciclo (eD -> eA), el costo total es 40, lo cual respeta K = 50.

instancia1 :: I
instancia1 = (v1, e1, w1, p1, x1, k1)
  where
    v1 = [eA, eB, eC, eD]
    
    e1 = [(eA, eB), (eB, eC), (eC, eD), (eD, eA), 
          (eA, eC), (eC, eB)] 
          
    w1 = [((eA, eB), 10), ((eB, eC), 10), ((eC, eD), 10), ((eD, eA), 10), 
          ((eA, eC), 80), ((eC, eB), 80)]
          
    p1 = [(eA, eC)] 
    
    x1 = [(eB, eD)] 
    
    k1 = 50         


-- ==========================================================
-- EJEMPLO 2: INSTANCIA IMPOSIBLE (Debería devolver Nothing)
-- ==========================================================
-- En esta instancia, la estación 'eD' está completamente aislada. 
-- No hay forma de llegar a ella ni de salir de ella respetando las aristas 'E'.

instancia2 :: I
instancia2 = (v2, e2, w2, p2, x2, k2)
  where
    v2 = [eA, eB, eC, eD]
    
    e2 = [(eA, eB), (eB, eC), (eC, eA)] 
    
    w2 = [((eA, eB), 10), ((eB, eC), 10), ((eC, eA), 10)]
    p2 = []
    x2 = []
    k2 = 100


-- ==========================================================
--                         EJERCICIO 2
-- ==========================================================

-- ==========================================
--  MACROS GLOBALES (COMPUERTAS LÓGICAS)
-- ==========================================

-- (rec orChi . (\x. \y. case x of [
--     True -> [] True [],
--     False -> [] y
-- ]))

-- (rec andChi . (\x. \y. case x of [
--     True -> [] y,
--     False -> [] False []
-- ]))

-- FUncion de igualdad realizada por IA
-- (rec igual . (\x. \y.
--     case x of [
--         A -> [] (case y of [
--             A -> [] True [],
--             B -> [] False [],
--             C -> [] False []
--         ]),
--         B -> [] (case y of [
--             A -> [] False [],
--             B -> [] True [],
--             C -> [] False []
--         ]),
--         C -> [] (case y of [
--             A -> [] False [],
--             B -> [] False [],
--             C -> [] True []
--         ])
--     ]
-- ))

notChi :: Chi
notChi = Lambda "x" (CaseOf (Var "x") [
            ("True", [], Const "False" []),
            ("False", [], Const "True" [])
         ])

andChi :: Chi
andChi = Lambda "x" (Lambda "y" (CaseOf (Var "x") [
            ("True", [], Var "y"),
            ("False", [], Const "False" [])
        ]))

-- (7) Or booleano
orChi :: Chi
orChi = Lambda "x" (Lambda "y" (CaseOf (Var "x") [
            ("True", [], Const "True" []),
            ("False", [], Var "y")
        ]))

-- Igual realizado por IA, dado que no se nos ocurrio como abordar dicha problematica

generarIgualChi :: [String] -> Chi
generarIgualChi dominio = 
    Lambda "x" (Lambda "y" (CaseOf (Var "x") (map crearRamaX dominio)))
  where
    crearRamaX valX = (valX, [], CaseOf (Var "y") (map (crearRamaY valX) dominio))
    
    crearRamaY valX valY 
        | valX == valY = (valY, [], Const "True" [])
        | otherwise    = (valY, [], Const "False" [])

-- 2. La función final que inyectas en tu verificador.
-- NOTA: Agrega a esta lista todas las variables o nodos que vayas a usar.
igualChi :: Chi
igualChi = generarIgualChi ["A", "B", "C", "D"]

-- ==========================================================
--                           PARTE 1.1
-- ==========================================================

-- ==========================================================
-- EJERCICIO A - Chi Puro
-- ==========================================================

-- (rec verifyA . (\p1. case p1 of [
--     Pair -> [domA,solA] (case solA of [
--         Just -> [m] (eval m domA),
--         Nothing -> [] False []
--     ]),
--     Nil -> [] False []
-- ]))

-- (rec eval . (\m. \e. case e of [
--     Nil -> [] True [],
--     Cons -> [t,xs] (andChi (evalTer m t) (eval m xs))
-- ]))

-- (rec evalTer . (\m. \t. case t of [
--     Nil -> [] False [],
--     Cons -> [l,ls] (orChi (evalLit m l) (evalTer m ls))
-- ]))

-- (rec evalLit . (\m. \v. case v of [
--     Pos -> [vm] (obtenerValor m vm),
--     Neg -> [vm] (notChi (obtenerValor m vm))
-- ]))

-- (rec obtenerValor . (\m. \v. case m of [
--     Nil -> [] False [],
--     Cons -> [vm,b,xs] (case (igual vm v) of [
--         True -> [] b,
--         False -> [] (obtenerValor xs v)
--     ]) 
-- ]))

-- ==========================================================
-- EJEMPLO A - Chi Puro
-- ==========================================================

-- Pair [
--     Cons [
--         Cons [Pos [A []], Nil []], 
--         Nil []
--     ], 
--     Just [
--         Cons [
--             Pair [A [], True []], 
--             Nil []
--         ]
--     ]
-- ]

-- Se espera True []

-- ==========================================================
-- EJERCICIO A - Chi Embebido
-- ==========================================================


obtenerValorChi :: Chi
obtenerValorChi = Rec "obtenerValor" (Lambda "m" (Lambda "v" (
        CaseOf (Var "m") [
            ("Nil", [], Const "False" []),
            ("Cons", ["vm", "b", "xs"], 
                CaseOf (App (App igualChi (Var "vm")) (Var "v")) [
                    ("True", [], Var "b"),
                    ("False", [], App (App (Var "obtenerValor") (Var "xs")) (Var "v"))
                ]
            )
        ]
    )))

evalLitChi :: Chi
evalLitChi = Lambda "m" (Lambda "v" (
        CaseOf (Var "v") [
            ("Pos",["vm"], App (App obtenerValorChi (Var "m")) (Var "vm")),
            ("Neg",["vm"], App notChi (App (App obtenerValorChi (Var "m")) (Var "vm")))
        ]
    ))

evalTerChi :: Chi
evalTerChi = Rec "evalTer" (Lambda "m" (Lambda "t" (
        CaseOf (Var "t") [
            ("Nil",[], Const "False" []),
            ("Cons",["l","ls"], App (App orChi (App (App evalLitChi (Var "m")) (Var "l"))) (App (App (Var "evalTer") (Var "m")) (Var "ls")))
        ]
    )))

evalExpChi :: Chi 
evalExpChi = Rec "eval" (Lambda "m" (Lambda "e" (
        CaseOf (Var "e") [
            ("Nil",[],Const "True" []),
            ("Cons",["t","xs"], App (App andChi (App (App evalTerChi (Var "m")) (Var "t"))) (App (App (Var "eval") (Var "m")) (Var "xs")))
        ]
    )))

verifyAChi :: Chi
verifyAChi = Lambda "p" (
        CaseOf (Var "p") [
            ("Pair", ["domA", "solA"], 
                CaseOf (Var "solA") [
                    ("Just", ["m"], App (App evalExpChi (Var "m")) (Var "domA")),
                    ("Nothing", [], Const "False" []) 
                ])
        ]
    )

-- ==========================================================
-- EJEMPLO A - Chi Embebido
-- ==========================================================

domATest :: Chi
domATest = Const "Cons" [
    Const "Cons" [Const "Pos" [Const "A" []], Const "Nil" []],
    Const "Cons" [
        Const "Cons" [Const "Neg" [Const "B" []], Const "Nil" []],
        Const "Nil" []
    ]]

solATest :: Chi
solATest = Const "Just" [
    Const "Cons" [Const "A" [], Const "True" [], 
        Const "Cons" [Const "B" [], Const "False" [], Const "Nil" []]
    ]]

inputATest :: Chi
inputATest = Const "Pair" [domATest, solATest]

-- Debería retornar: Const "True" []

-- ==========================================================
-- EJERCICIO B - Chi Puro
-- ==========================================================

-- (rec verifyB . (\p1. case p1 of [
--     Pair -> [domB,solB] (case solB of [
--         Just -> [s] (esSecuenciaValida domB s),
--         Nothing -> [] False []
--     ]),
--     Nil -> [] False []
-- ]))

-- (rec esSecuenciaValida . (\i. \s. case i of [
--     Entorno -> [v,e,w,p,x,k] (
--         andChi (verificarCoberturaTotal v s) (
--             andChi (verificarTransiciones e s) (
--                 andChi (verificarPrecedencias p s) 
--                     (andChi (verificarExclusiones x s) (verificarCotas w k s))
--             )
--         )
--     )
-- ]))

-- (rec verificarCoberturaTotal . (\v. \s. case v of [
--     Nil -> [] (case s of [
--         Nil -> [] True [],
--         Cons -> [s1,xs] False []
--     ]),
--     Cons -> [v1,vs] (case (pertenece v1 s) of [
--         True -> [] (verificarCoberturaTotal vs (borrarUnaVez v1 s)),
--         False -> [] False []
--     ]) 
-- ]))

-- (rec verificarTransiciones . (\e. \s. 
--     case s of [
--         Nil -> [] True [],
--         Cons -> [s1, xs] (
--             case xs of [
--                 Nil -> [] True [],
--                 Cons -> [s2, ls] (
--                     andChi 
--                         (encontrarTrans e (Pair s1 s2)) 
--                         (verificarTransiciones e (Cons s2 ls))
--                 )
--             ]
--         )
--     ]
-- ))

-- (rec verificarPrecedencias . (\p. \s. 
--     case s of [
--         Nil -> [] True [],
--         Cons -> [s1,xs] (
--             case xs of [
--                 Nil -> [] True [],
--                 Cons -> [s2,ss] ( 
--                     case p of [
--                         Nil -> [] True [],
--                         Cons -> [p1,ps] (
--                             andChi 
--                                 (cumplePrecedencia p1 s)
--                                 (verificarPrecedencias ps s)
--                         )
--                     ]
--                 )
--             ]
--         )
--     ]
-- ))

-- (rec verificarExclusiones . (\x. \s.
--     case s of [
--         Nil -> [] True [],
--         Cons -> [s1,xs] (
--             case xs of [
--                 Nil -> [] True [],
--                 Cons -> [s2,ls] (
--                     andChi 
--                         (notChi (encontrarTrans x (Pair s1 s2)))
--                         (verificarExclusiones x (Cons s2 ls))
--                 )
--             ]
--         )
--     ]
-- ))

-- (rec verificarCotas . (\w. \k. \s. 
--     menorIgual (sumarCostos w s Z) k
-- ))

-- (rec pertenece . (\x. \s. 
--     case s of [
--         Nil -> [] False [],
--         Cons -> [s1,ls] (
--             case (igual x s1) of [
--                 True -> [] True [],
--                 False -> [] (pertenece x ls)
--             ]
--         )
--     ]
-- ))

-- (rec borrarUnaVez . (\e. \s.  
--     case s of [
--         Nil -> [] Nil [],
--         Cons -> [s1,ls] (
--             case (igual e s1) of [
--                 True -> [] ls,
--                 False -> [] (Cons s1 (borrarUnaVez e ls))
--             ]
--         )
--     ]
-- ))

-- (rec encontrarTrans . (\le. \p.
--     case le of [
--         Nil -> [] False [],
--         Cons -> [e,ls] (
--             case e of [
--                 Nil -> [] False [],
--                 Pair -> [e1,e2] (
--                     case p of [
--                         Nil -> [] False [],
--                         Pair -> [p1,p2] (
--                             case (andChi (igual e1 p1) (igual e2 p2)) of [
--                                 True -> [] True [],
--                                 False -> [] (encontrarTrans ls p)
--                             ] 
--                         )
--                     ]
--                 )
--             ]
--         )
--     ]
-- ))

-- (rec cumplePrecedencia . (\p. \s. 
--     case s of [
--         Nil -> [] True [],
--         Cons -> [s1,ls] (
--             case p of [
--                 Nil -> [] True [],
--                 Pair -> [u,v] (
--                     case (igual s1 v) of [
--                         True -> [] (noAparece u ls),
--                         False -> [] (
--                             case (igual s1 u) of [
--                                 True -> [] (pertenece v ls),
--                                 False -> [] (cumplePrecedencia (Pair u v) ls)
--                             ]
--                         )
--                     ]
--                 )
--             ]
--         )
--     ]
-- ))

-- (rec noAparece . (\e. \s. 
--     case s of [
--         Nil -> [] True [],
--         Cons -> [s1,ls] (
--             case (igual s1 e) of [
--                 True -> [] False [],
--                 False -> [] (noAparece e ls)
--             ]
--         )
--     ]
-- ))

-- (rec sumarCostos . (\w. \s. \k. 
--     case s of [
--         Nil -> [] k,
--         Cons -> [s1,ls] (
--             case ls of [
--                 Nil -> [] k,
--                 Cons -> [s2,ss] (sumarCostos w (Cons s2 ss) (sumarChi k (darCostoTrans w (Pair s1 s2))))
--             ]
--         )
--     ]
-- ))

-- (rec darCostoTrans . (\w. \p. 
--     case w of [
--         Nil -> [] Z [],
--         Cons -> [a,c,ws] (
--             case p of [
--                 Nil -> [] Z [],
--                 Pair -> [e1,e2] (
--                     case a of [
--                         Nil -> [] (darCostoTrans ws (Pair e1 e2)),
--                         Pair -> [w1,w2] (case (andChi (igual w1 e1) (igual w2 e2)) of [
--                             True -> [] c,
--                             False -> [] (darCostoTrans ws (Pair e1 e2))
--                         ])
--                     ]
--                 )
--             ]
--         )
--     ]
-- ))

-- (rec menorIgual . (\n. \k.
--     case n of [
--         Z -> [] True [],
--         S -> [x] (
--             case k of [
--                 Z -> [] False [],
--                 S -> [y] (menorIgual x y) 
--             ]
--         )
--     ]
-- ))

-- (rec sumarChi . (\n. \m.
--     case n of [
--         Z -> [] m,
--         S -> [x] (S (sumarChi x m))
--     ]
-- ))

-- ==========================================================
-- EJEMPLO B - Chi Puro
-- ==========================================================

-- Pair [
--     Entorno [
--         Cons [A [], Cons [B [], Nil []]], 
--         Cons [Pair [A [], B []], Nil []], 
--         Nil [], 
--         Nil [], 
--         Nil [], 
--         S [S [Z []]]
--     ], 
--     Just [
--         Cons [A [], Cons [B [], Nil []]]
--     ]
-- ]

-- Se espera True []

-- ==========================================================
-- EJERCICIO B - Chi Embebido
-- ==========================================================

verifyBChi :: Chi
verifyBChi = Lambda "p" (
        CaseOf (Var "p") [
            ("Nil", [], Const "False" []),
            ("Pair", ["domB", "solB"], 
                CaseOf (Var "solB") [
                    ("Just", ["s"], App (App esSecuenciaValidaChi (Var "domB")) (Var "s")),
                    ("Nothing", [], Const "False" [])
                ])
        ]
    )

esSecuenciaValidaChi :: Chi
esSecuenciaValidaChi = Lambda "i" (Lambda "s" (
        CaseOf (Var "i") [
            ("Entorno", ["v", "e", "w", "p", "x", "k"],
                App (App andChi (App (App verificarCoberturaTotalChi (Var "v")) (Var "s"))) (
                    App (App andChi (App (App verificarTransicionesChi (Var "e")) (Var "s"))) (
                        App (App andChi (App (App verificarPrecedenciasChi (Var "p")) (Var "s"))) (
                            App (App andChi (App (App verificarExclusionesChi (Var "x")) (Var "s"))) (
                                App (App (App verificarCotasChi (Var "w")) (Var "k")) (Var "s")
                            )
                        )
                    )
                )
            )
        ]
    ))

verificarCoberturaTotalChi :: Chi
verificarCoberturaTotalChi = Rec "verificarCoberturaTotal" (Lambda "v" (Lambda "s" (
        CaseOf (Var "v") [
            ("Nil", [], CaseOf (Var "s") [
                ("Nil", [], Const "True" []),
                ("Cons", ["s1", "xs"], Const "False" [])
            ]),
            ("Cons", ["v1", "vs"], CaseOf (App (App perteneceChi (Var "v1")) (Var "s")) [
                ("True", [], App (App (Var "verificarCoberturaTotal") (Var "vs")) (App (App borrarUnaVezChi (Var "v1")) (Var "s"))),
                ("False", [], Const "False" [])
            ])
        ]
    )))

verificarTransicionesChi :: Chi
verificarTransicionesChi = Rec "verificarTransiciones" (Lambda "e" (Lambda "s" (
        CaseOf (Var "s") [
            ("Nil", [], Const "True" []),
            ("Cons", ["s1", "xs"], CaseOf (Var "xs") [
                ("Nil", [], Const "True" []),
                ("Cons", ["s2", "ls"], 
                    App (App andChi 
                        (App (App encontrarTransChi (Var "e")) (Const "Pair" [Var "s1", Var "s2"])))
                        (App (App (Var "verificarTransiciones") (Var "e")) (Const "Cons" [Var "s2", Var "ls"]))
                )
            ])
        ]
    )))

verificarPrecedenciasChi :: Chi
verificarPrecedenciasChi = Rec "verificarPrecedencias" (Lambda "p" (Lambda "s" (
        CaseOf (Var "s") [
            ("Nil", [], Const "True" []),
            ("Cons", ["s1", "xs"], CaseOf (Var "xs") [
                ("Nil", [], Const "True" []),
                ("Cons", ["s2", "ss"], CaseOf (Var "p") [
                    ("Nil", [], Const "True" []),
                    ("Cons", ["par", "ps"], 
                        App (App andChi 
                            (App (App cumplePrecedenciaChi (Var "par")) (Var "s")))
                            (App (App (Var "verificarPrecedencias") (Var "ps")) (Var "s"))
                    )
                ])
            ])
        ]
    )))

verificarExclusionesChi :: Chi
verificarExclusionesChi = Rec "verificarExclusiones" (Lambda "x" (Lambda "s" (
        CaseOf (Var "s") [
            ("Nil", [], Const "True" []),
            ("Cons", ["s1", "xs"], CaseOf (Var "xs") [
                ("Nil", [], Const "True" []),
                ("Cons", ["s2", "ls"], 
                    App (App andChi 
                        (App notChi (App (App encontrarTransChi (Var "x")) (Const "Pair" [Var "s1", Var "s2"]))))
                        (App (App (Var "verificarExclusiones") (Var "x")) (Const "Cons" [Var "s2", Var "ls"]))
                )
            ])
        ]
    )))

verificarCotasChi :: Chi
verificarCotasChi = Lambda "w" (Lambda "k" (Lambda "s" (
        App (App menorIgualKChi (App (App (App sumarCostosChi (Var "w")) (Var "s")) (Const "Z" []))) (Var "k")
    )))

perteneceChi :: Chi
perteneceChi = Rec "pertenece" (Lambda "x" (Lambda "s" (
        CaseOf (Var "s") [
            ("Nil", [], Const "False" []),
            ("Cons", ["s1", "ls"], CaseOf (App (App igualChi (Var "x")) (Var "s1")) [
                ("True", [], Const "True" []),
                ("False", [], App (App (Var "pertenece") (Var "x")) (Var "ls"))
            ])
        ]
    )))

borrarUnaVezChi :: Chi
borrarUnaVezChi = Rec "borrarUnaVez" (Lambda "e" (Lambda "s" (
        CaseOf (Var "s") [
            ("Nil", [], Const "Nil" []),
            ("Cons", ["s1", "ls"], CaseOf (App (App igualChi (Var "e")) (Var "s1")) [
                ("True", [], Var "ls"),
                ("False", [], Const "Cons" [Var "s1", App (App (Var "borrarUnaVez") (Var "e")) (Var "ls")])
            ])
        ]
    )))

encontrarTransChi :: Chi
encontrarTransChi = Rec "encontrarTrans" (Lambda "le" (Lambda "p" (
        CaseOf (Var "le") [
            ("Nil", [], Const "False" []),
            ("Cons", ["e", "ls"], CaseOf (Var "e") [
                ("Nil", [], Const "False" []),
                ("Pair", ["e1", "e2"], CaseOf (Var "p") [
                    ("Nil", [], Const "False" []),
                    ("Pair", ["p1", "p2"], 
                        CaseOf (App (App andChi (App (App igualChi (Var "e1")) (Var "p1"))) (App (App igualChi (Var "e2")) (Var "p2"))) [
                            ("True", [], Const "True" []),
                            ("False", [], App (App (Var "encontrarTrans") (Var "ls")) (Var "p"))
                        ]
                    )
                ])
            ])
        ]
    )))

cumplePrecedenciaChi :: Chi
cumplePrecedenciaChi = Rec "cumplePrecedencia" (Lambda "p" (Lambda "s" (
        CaseOf (Var "s") [
            ("Nil", [], Const "True" []),
            ("Cons", ["s1", "ls"], CaseOf (Var "p") [
                ("Nil", [], Const "True" []),
                ("Pair", ["u", "v"], CaseOf (App (App igualChi (Var "s1")) (Var "v")) [
                    ("True", [], App (App noApareceChi (Var "u")) (Var "ls")),
                    ("False", [], CaseOf (App (App igualChi (Var "s1")) (Var "u")) [
                        ("True", [], App (App perteneceChi (Var "v")) (Var "ls")),
                        ("False", [], App (App (Var "cumplePrecedencia") (Const "Pair" [Var "u", Var "v"])) (Var "ls"))
                    ])
                ])
            ])
        ]
    )))

noApareceChi :: Chi
noApareceChi = Rec "noAparece" (Lambda "e" (Lambda "s" (
        CaseOf (Var "s") [
            ("Nil", [], Const "True" []),
            ("Cons", ["s1", "ls"], CaseOf (App (App igualChi (Var "s1")) (Var "e")) [
                ("True", [], Const "False" []),
                ("False", [], App (App (Var "noAparece") (Var "e")) (Var "ls"))
            ])
        ]
    )))

sumarCostosChi :: Chi
sumarCostosChi = Rec "sumarCostos" (Lambda "w" (Lambda "s" (Lambda "k" (
        CaseOf (Var "s") [
            ("Nil", [], Var "k"),
            ("Cons", ["s1", "ls"], CaseOf (Var "ls") [
                ("Nil", [], Var "k"),
                ("Cons", ["s2", "ss"],
                    App (App (App (Var "sumarCostos") (Var "w")) (Const "Cons" [Var "s2", Var "ss"])) 
                        (App (App sumarChi (Var "k")) (App (App darCostoTransChi (Var "w")) (Const "Pair" [Var "s1", Var "s2"])))
                )
            ])
        ]
    ))))

darCostoTransChi :: Chi
darCostoTransChi = Rec "darCostoTrans" (Lambda "w" (Lambda "p" (
        CaseOf (Var "w") [
            ("Nil", [], Const "Z" []),
            ("Cons", ["a", "c", "ws"], CaseOf (Var "p") [
                ("Nil", [], Const "Z" []),
                ("Pair", ["e1", "e2"], CaseOf (Var "a") [
                    ("Nil", [], App (App (Var "darCostoTrans") (Var "ws")) (Var "p")),
                    ("Pair", ["w1", "w2"], 
                        CaseOf (App (App andChi (App (App igualChi (Var "w1")) (Var "e1"))) (App (App igualChi (Var "w2")) (Var "e2"))) [
                            ("True", [], Var "c"),
                            ("False", [], App (App (Var "darCostoTrans") (Var "ws")) (Var "p"))
                        ]
                    )
                ])
            ])
        ]
    )))

menorIgualKChi :: Chi
menorIgualKChi = Rec "menorIgual" (Lambda "n" (Lambda "k" (
        CaseOf (Var "n") [
            ("Z", [], Const "True" []),
            ("S", ["x"], CaseOf (Var "k") [
                ("Z", [], Const "False" []),
                ("S", ["y"], App (App (Var "menorIgual") (Var "x")) (Var "y"))
            ])
        ]
    )))

sumarChi :: Chi
sumarChi = Rec "sumar" (Lambda "n" (Lambda "m" (
        CaseOf (Var "n") [
            ("Z", [], Var "m"),
            ("S", ["x"], Const "S" [App (App (Var "sumar") (Var "x")) (Var "m")])
        ]
    )))

-- ==========================================================
-- EJEMPLO B - Chi Embebido
-- ==========================================================

secuenciaTestB :: Chi
secuenciaTestB = Const "Cons" [Const "A" [], Const "Cons" [Const "B" [], Const "Nil" []]]

entornoTestB :: Chi
entornoTestB = Const "Entorno" [
    Const "Cons" [Const "A" [], Const "Cons" [Const "B" [], Const "Nil" []]],
    Const "Cons" [Const "Pair" [Const "A" [], Const "B" []], Const "Nil" []],
    Const "Cons" [Const "Pair" [Const "Pair" [Const "A" [], Const "B" []], Const "S" [Const "Z" []]], Const "Nil" []],
    Const "Nil" [],
    Const "Nil" [],
    Const "S" [Const "S" [Const "Z" []]]
  ]

inputBTest :: Chi
inputBTest = Const "Pair" [entornoTestB, Const "Just" [secuenciaTestB]]

-- Debería retornar: Const "True" []