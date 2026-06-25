{-# LANGUAGE BlockArguments #-}
module Lab2 where

data P = Assig [X] [E]
    | Local [X] P
    | Sec P P
    | Case X [B]
    | While X [B]
    | Def F [X] X P
    | Call F [E] X
    deriving Show

data E = Cons C [E]
    | Var X
    deriving Show

type B = (C,[X],P)

type X = String
type C = String

-- Semantica

data V = VCons C [V]
    | NULL

type M = [(X,V)]

-- Funciones Auxiliares

busqueda :: M -> X -> V
busqueda [] _ = NULL
busqueda ((a,b):ms) x
    | a == x = b
    | otherwise = busqueda ms x

actualizarSimp :: M -> (X,V) -> M
actualizarSimp [] b = [b]
actualizarSimp ((x,y):ms) (ax,v)
    | x == ax = (ax,v):ms
    | otherwise = (x,y):(actualizarSimp ms (ax,v))

actualizar :: M -> [(X,V)] -> M
actualizar m [] = m
actualizar m (b:bs) = actualizar (actualizarSimp m b) bs

alta :: M -> [X] -> M
alta m [] = m
alta m (x:xs) = (x,NULL):(alta m xs)

elim :: M -> X -> M
elim [] _ = []
elim ((ax, v):ms) x
    | x == ax = ms
    | otherwise = (ax,v):(elim ms x)

bajas :: M -> [X] -> M
bajas m [] = m
bajas m (x:xs) = bajas (elim m x) xs

mix :: [a] -> [b] -> [(a,b)]
mix [] _ = []
mix _ [] = []
mix (a:as) (b:bs) = (a,b):(mix as bs)

buscarRama :: C -> [B] -> Maybe B
buscarRama c [] = Nothing
buscarRama c (((cb,xs,p)):bs)
    | c == cb = Just (cb,xs,p)
    | otherwise = buscarRama c bs

-- Reglas evaluacion

evalE :: M -> E -> V
evalE m (Cons c es) = VCons c (map (evalE m) es)
evalE m (Var x) = busqueda m x


exe :: M -> P -> M
exe m (Assig xs es) =
    let vs = map (evalE m) es
    in actualizar m (mix xs vs)

exe m (Local xs p) =
    let m' = exe (alta m xs) p
    in bajas m' xs

exe m (Sec p1 p2) =
    let m' = exe m p1
    in exe m' p2

exe m (Case x bs) =
    case busqueda m x of
        NULL -> m
        VCons c vs ->
            case buscarRama c bs of
                Nothing -> m
                Just (_, xs, p) ->
                    let mTemp = mix xs vs ++ m
                        m' = exe mTemp p
                    in bajas m' xs

exe m (While x bs) =
    case busqueda m x of
        NULL -> m
        VCons c vs ->
            case buscarRama c bs of
                Nothing -> m
                Just (_, xs, p) ->
                    let mTemp = mix xs vs ++ m
                        m' = exe mTemp p
                        m'' = bajas m' xs
                    in exe m'' (While x bs)






par :: P
par = 
    Local ["res", "n'"] (
      Sec 
        (Assig ["res", "n'"] [Cons "True" [], Var "n"]) 
        (While "n'" [
            ("suc", ["x"] , 
                Sec 
                    (Case "res" [
                        ("True", [], Assig ["res"] [Cons "False" []]),
                        ("False", [], Assig ["res"] [Cons "True" []])
                ])
                (Assig ["n'"] [Var "x"])
            )
        ])
    )

suma :: P
suma = 
    Local ["res","n1" , "n2"](
        Sec
        (Assig ["res", "n1", "n2"] [ Var "n1", Var "n1", Var "n2"])
        While "n2" [
            ("suc", ["x"], 
                Sec
                    (Assig ["res"] [Cons "suc" [Var "res"]])
                    (Assig ["n2"] [Var "x"])
            )
        ]
    )

unitsofmeasure :: P
unitsofmeasure = 
    Local ["res", "l"](
        Sec
        (Assig ["res", "l"] [ Cons "O" [], Var "l"])
        (While "l" [
            ("Cons",["x","xs"], 
                Sec
                    (Assig ["res"] [Cons "suc" [Var "res"]])
                    (Assig ["l"] [Var "xs"])
            )
        ])
    )

iguales :: P
iguales =
  Local ["res","n1","n2"] (
    Sec
      (Assig ["res","n1","n2"] [Cons "True" [], Var "n1", Var "n2"])
      (While "n1" [

        ("suc", ["x"],
          Case "n2" [
            ("suc", ["y"],
              Sec
                (Assig ["n1","n2"] [Var "x", Var "y"])  -- clave
                (Assig ["res"] [Var "res"])            -- no tocar
            ),
            ("O", [],
              Assig ["res"] [Cons "False" []]
            )
          ]
        ),

        ("O", [],
          Case "n2" [
            ("suc", ["y"],
              Assig ["res"] [Cons "False" []]
            ),
            ("O", [],
              Assig ["res"] [Cons "True" []]
            )
          ]
        )
      ])
  )

  concatP :: P
  concatP = 
    Local ["res", "l1", "l2"] (
      Sec
        (Assig ["res", "l1", "l2"] [Var "l2", Var "l1", Var "l2"])
        (While "l1" [
          ("Cons", ["x","xs"],
            Sec
              (Assig ["res"] [Cons "Cons" [Var "x", Var "res"]])
              (Assig ["l1"] [Var "xs"])
          )
        ])
    )
    

    -- extension para la part7
    
type F = String
type Delta = [(F, [X], X, P)]






