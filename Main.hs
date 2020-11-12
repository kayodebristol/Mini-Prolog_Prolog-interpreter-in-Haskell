module Main where
import MiniProlog

main :: IO ()
main = return()

kb = [(P "male" [Cons "timmy"],[]), (P "male" [Cons "alex"],[]), (P "male" [Cons "slim"],[]), (P "male" [Cons "azmy"],[]), (P "male" [Cons "remon"],[]), (P "female" [Cons "amira"],[]), (P "female" [Cons "reem"],[]), (P "female" [Cons "wanda"],[]), (P "parent" [Cons "slim", Cons "amira"],[]), (P "parent" [Cons "wanda", Cons "timmy"],[]), (P "parent" [Cons "azmy", Cons "reem"],[]), (P "parent" [Cons "azmy", Cons "remon"],[]), (P "father" [Var "X", Var "Y"], [P "male" [Var "X"], P "parent" [Var "X", Var "Y"]]), (P "daughterFather" [Var "X", Var "Y"], [P "father" [Var "Y", Var "X"], P "female" [Var "X"]])]