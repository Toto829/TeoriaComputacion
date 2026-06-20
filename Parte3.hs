module Part3 where

import Lab2

-- =========================================================
-- BASE
-- =========================================================

-- Programa vacio
skip :: P
skip = Assig [] []

-- Secuencia de varios programas
sec :: [P] -> P
sec [] = skip
sec [p] = p
sec (p:ps) = Sec p (sec ps)

-- Booleanos
trueE :: E
trueE = Cons "True" []

falseE :: E
falseE = Cons "False" []

trueV :: V
trueV = VCons "True" []

falseV :: V
falseV = VCons "False" []

-- Naturales de Peano
oE :: E
oE = Cons "O" []

sucE :: E -> E
sucE e = Cons "suc" [e]

natE :: Int -> E
natE 0 = oE
natE n = sucE (natE (n - 1))

oV :: V
oV = VCons "O" []

sucV :: V -> V
sucV v = VCons "suc" [v]

natV :: Int -> V
natV 0 = oV
natV n = sucV (natV (n - 1))

-- Listas
nilE :: E
nilE = Cons "Nil" []

consE :: E -> E -> E
consE x xs = Cons "Cons" [x, xs]

nilV :: V
nilV = VCons "Nil" []

consV :: V -> V -> V
consV x xs = VCons "Cons" [x, xs]

-- Par
pairE :: E -> E -> E
pairE a b = Cons "Pair" [a, b]

pairV :: V -> V -> V
pairV a b = VCons "Pair" [a, b]

-- Literales SAT
posE :: Int -> E
posE n = Cons "Pos" [natE n]

negE :: Int -> E
negE n = Cons "Neg" [natE n]

posV :: Int -> V
posV n = VCons "Pos" [natV n]

negV :: Int -> V
negV n = VCons "Neg" [natV n]

type VarSAT = Int

data LitSAT = PosSAT VarSAT | NegSAT VarSAT
  deriving Show

type ClausulaSAT = [LitSAT]
type FormulaSAT = [ClausulaSAT]
type InterpSAT = [(VarSAT, Bool)]

-- =========================================================
-- CODIFICACION A VALORES DE IMP
-- =========================================================

codBoolV :: Bool -> V
codBoolV True = trueV
codBoolV False = falseV

codLitV :: LitSAT -> V
codLitV (PosSAT n) = posV n
codLitV (NegSAT n) = negV n

codListaV :: [V] -> V
codListaV [] = nilV
codListaV (x:xs) = consV x (codListaV xs)

codClausulaV :: ClausulaSAT -> V
codClausulaV xs = codListaV (map codLitV xs)

codFormulaV :: FormulaSAT -> V
codFormulaV xs = codListaV (map codClausulaV xs)

codInterpV :: InterpSAT -> V
codInterpV [] = nilV
codInterpV ((n,b):xs) =
  consV (pairV (natV n) (codBoolV b)) (codInterpV xs)

-- =========================================================
-- MEMORIA INICIAL PARA VERIFY_SAT
-- =========================================================

memVerifySAT :: FormulaSAT -> InterpSAT -> M
memVerifySAT clausulas interpretacion =
  [ ("clausulas", codFormulaV clausulas)
  , ("interpretacion", codInterpV interpretacion)
  , ("res", falseV)
  ]

-- =========================================================
-- SUBPROGRAMAS BASE
-- =========================================================
-- ---------------------------------------------------------
-- igualdadNat
--
-- Entradas:
--   n1, n2
--
-- Salida:
--   resIgual
--
-- IDEA:
--   comparas n1 y n2
--   cuando lo implementemos, lo mas natural es hacerlo
--   muy parecido a tu programa "iguales"
-- ---------------------------------------------------------

igualdadNat :: P
igualdadNat =
  Local ["a","b"] (
    Sec
      (Assig ["res", "a", "b"] [trueE, Var "n1", Var "n2"])
      (Sec
        (While "a" [
          ("suc", ["x"],
            Case "b" [
              ("suc", ["y"],
                Assig ["a","b"] [Var "x", Var "y"]
              ),
              ("O", [],
                Sec
                  (Assig ["res"] [falseE])
                  (Assig ["a"] [oE])
              )
            ]
          )
        ])
        (Case "b" [
          ("O", [],
            Assig ["res"] [Var "res"]
          ),
          ("suc", ["y"],
            Assig ["res"] [falseE]
          )
        ])
      )
  )

-- ---------------------------------------------------------
-- negarBool
--
-- Entrada:
--   b
--
-- Salida:
--   resNeg
-- ---------------------------------------------------------

negarBool :: P
negarBool =
  Case "b"
    [ ("True", [], Assig ["resNeg"] [falseE])
    , ("False", [], Assig ["resNeg"] [trueE])
    ]

-- ---------------------------------------------------------
-- buscarEnInterp
--
-- Entradas:
--   varBuscada, interpretacion
--
-- Salida:
--   resBusqueda
--
-- IDEA:
--   recorrer la interpretacion hasta encontrar
--   Pair(varBuscada, bool)
-- ---------------------------------------------------------

buscarEnInterp :: P
buscarEnInterp =
  Local ["interp", "encontre", "parActual", "restoInterp", "varPar", "boolPar"] (
    sec
      [ Assig ["interp", "encontre", "resBusqueda"]
          [Var "interpretacion", falseE, falseE]

      , While "interp"
          [ ("Cons", ["parActual", "restoInterp"],
              sec
                [ Case "parActual"
                    [ ("Pair", ["varPar", "boolPar"],
                        sec
                          [ Assig ["n1", "n2"] [Var "varBuscada", Var "varPar"]

                          , igualdadNat

                          , Case "resIgual"
                              [ ("True", [],
                                  sec
                                    [ Assig ["encontre", "resBusqueda"]
                                        [trueE, Var "boolPar"]
                                    , Assig ["interp"] [nilE]
                                    ]
                                )
                              , ("False", [],
                                  skip
                                )
                              ]
                          ]
                      )
                    ]

                , Case "encontre"
                    [ ("True", [],
                        skip
                      )
                    , ("False", [],
                        Assig ["interp"] [Var "restoInterp"]
                      )
                    ]
                ]
            )
          ]
      ]
  )
-- ---------------------------------------------------------
-- evaluarLiteral
--
-- Entradas:
--   litActual, interpretacion
--
-- Salida:
--   resLit
-- ---------------------------------------------------------

evaluarLiteral :: P
evaluarLiteral =
  Local ["v", "b"] (
    Case "litActual"
      [ ("Pos", ["v"],
          sec
            [ Assig ["varBuscada"] [Var "v"]

            , buscarEnInterp

            , Assig ["resLit"] [Var "resBusqueda"]
            ]
        )

      , ("Neg", ["v"],
          sec
            [ Assig ["varBuscada"] [Var "v"]

            , buscarEnInterp

            , Assig ["b"] [Var "resBusqueda"]

            , Case "b"
                [ ("True", [], Assig ["resLit"] [falseE])
                , ("False", [], Assig ["resLit"] [trueE])
                ]
            ]
        )
      ]
  )

-- ---------------------------------------------------------
-- evaluarClausula
--
-- Entradas:
--   clausulaActual, interpretacion
--
-- Salida:
--   resClausula
--
-- IDEA:
--   OR de todos los literales
-- ---------------------------------------------------------

evaluarClausula :: P
evaluarClausula =
  Local ["cls", "lit", "restoLits"] (
    sec
      [ Assig ["cls", "resClausula"] [Var "clausulaActual", falseE]

      , While "cls"
          [ ("Cons", ["lit", "restoLits"],
              sec
                [
                  
                  Assig ["litActual"] [Var "lit"]

                , -
                  evaluarLiteral

                , 
                  Case "resLit"
                    [ ("True", [], Assig ["resClausula"] [trueE])
                    , ("False", [], skip)
                    ]

                , -- avanzar la lista
                  Assig ["cls"] [Var "restoLits"]
                ]
            )
          ]
      ]
  )

-- ---------------------------------------------------------
-- verifySAT
--
-- Entradas:
--   clausulas, interpretacion
--
-- Salida:
--   res
--
-- IDEA:
--   AND de todas las clausulas
-- ---------------------------------------------------------

verifySAT :: P
verifySAT =
  Local ["cls", "clausulaActual", "restoCls"] (
    sec
      [ Assig ["res", "cls"] [trueE, Var "clausulas"]

      , While "cls"
          [ ("Cons", ["clausulaActual", "restoCls"],
              sec
                [
                  
                  evaluarClausula

                , 
                  Case "resClausula"
                    [ ("False", [], Assig ["res"] [falseE])
                    , ("True", [], skip)
                    ]

                , 
                  Assig ["cls"] [Var "restoCls"]
                ]
            )
          ]
      ]
  )


-- =========================================================
-- AYUDAS PARA CORRER TESTS
-- =========================================================

correrVerifySAT :: FormulaSAT -> InterpSAT -> V
correrVerifySAT clausulas interpretacion =
  let m0 = memVerifySAT clausulas interpretacion
      m1 = exe m0 verifySAT
  in busqueda m1 "res"

mostrarMemVerifySAT :: FormulaSAT -> InterpSAT -> M
mostrarMemVerifySAT clausulas interpretacion =
  let m0 = memVerifySAT clausulas interpretacion
  in exe m0 verifySAT

-- =========================================================
-- EJEMPLOS DE PRUEBA
-- =========================================================

-- Ejemplo 1 de la letra:
-- (x1 v ~x2 v x3) ^ (~x1 v x2 v x3) ^ (x2 v x3)

ej1 :: FormulaSAT
ej1 =
  [ [PosSAT 1, NegSAT 2, PosSAT 3]
  , [NegSAT 1, PosSAT 2, PosSAT 3]
  , [PosSAT 2, PosSAT 3]
  ]

interpEj1Ok :: InterpSAT
interpEj1Ok =
  [ (1, True)
  , (2, True)
  , (3, False)
  ]

interpEj1No :: InterpSAT
interpEj1No =
  [ (1, False)
  , (2, False)
  , (3, False)
  ]

-- Ejemplo 2 de la letra:
-- (x1) ^ (x2 v x3) ^ (~x1)

ej2 :: FormulaSAT
ej2 =
  [ [PosSAT 1]
  , [PosSAT 2, PosSAT 3]
  , [NegSAT 1]
  ]

interpEj2 :: InterpSAT
interpEj2 =
  [ (1, True)
  , (2, False)
  , (3, False)
  ]


