module MiniProlog where
data Term = Cons String -- Term
	   	| Var String deriving (Show, Eq)

data Predicate = P String [Term] -- Predicate
	deriving (Show, Eq)

type Goals = [Predicate]  -- Goals are a list of Predicates

type Rule = (Predicate,Goals)  -- Rules are formed of a pair (Predicate, Goals)
							   -- A Fact is modeled as a Rule with an empty body (Goals)

data Solution = No -- A Solution is a list of required Variable Bindings for a Predicate to hold
	   | Yes [(Term,Term)]
	   deriving (Show, Eq)


-- Checks if a Variable (1st Argument) is not bounded in the List of bindings (2nd Argument) to something different

notBoundedToAnother (a, b) [] = True
notBoundedToAnother (Var a, Cons b) ((Var c, Cons d):ys) = if (a == c) then if (b == d) then True
																			else False
													  	   else notBoundedToAnother	(Var a, Cons b) ys

-- Checks if there is no Contradiction between two Solutions (The 2 Arguments) if one has a Variable bound to something and the other has the same Variable bound to something else

noContradiction (Yes []) (Yes list) = True													  
noContradiction (Yes (x:xs)) (Yes list) = if (notBoundedToAnother x list) then noContradiction (Yes xs) (Yes list)
										  else False

-- Combines 2 Solutions: taking care of duplicates. also If one Predicate never holds (No) neither will the other.
-- Checks for duplicates but doesn't check for Contradictions (Variable bound to 2 different things)

combineSol No _ = No 
combineSol _ No = No 
combineSol (Yes x) (Yes y) = combineSol1 (Yes x) (Yes x) (Yes y)
-- "curList" Same as Accumelator in prolog
combineSol1 (Yes curList) (Yes x) (Yes []) = Yes curList
combineSol1 (Yes curList) (Yes x) (Yes (y:ys)) = if (elem y x) then combineSol1 (Yes curList) (Yes x) (Yes ys)
												 else combineSol1 (Yes (curList ++ [y])) (Yes x) (Yes ys)


-- Combines multiple Solutions from current Predicate (1st Argument) with the current Solution (2nd Argument)
-- Checks for Contradictions


combineSols [] list = []

combineSols ((Yes a):xs) list = combineSols1 (Yes a) list ++ combineSols xs list



combineSols1 (Yes a) (y:ys) = if noContradiction (Yes a) y then (combineSol (Yes a) y) : combineSols1 (Yes a) ys
							  else combineSols1 (Yes a) ys

combineSols1 (Yes a) [] = []

-- Combines all given Lists of Solutions (each List comes from a Predicate)

combineAllSols (x:xs) = combineSols x (combineAllSols xs)
combineAllSols [] = [Yes []]

-- matches one element in Solution (1st Argument) with the elements in a Predicate (2nd Argument)

match (a, b) [] = []
match (Var a, Cons b) ((Var y):ys) = if a == y then (Cons b):(match (Var a, Cons b) ys)
									 else (Var y):(match(Var a, Cons b) ys)

match (a, b) ((Cons y):ys) = (Cons y):(match(a, b) ys)

match (Var a, Var b) ((Var y):ys) = if a == y then (Var b):(match (Var a, Var b) ys)
									else (Var y):(match(Var a, Var b) ys)

-- Apply Solution in the body composed of multiple Predicates, map function to apply to each Predicate in body

applySolSubInBody (Yes solBindings) body = map (applySolSubInPredicate solBindings) body

-- Apply Solution in the current Predicate by finding matches of of every binding in the current Solution (1st Argument) in the terms of the Predicate

applySolSubInPredicate solBindings (P name terms) = (P name (applySolSubInPredicate1 solBindings terms))

applySolSubInPredicate1 [] terms = terms
applySolSubInPredicate1 (x:xs) terms = applySolSubInPredicate1 xs ((match x) terms)

-- tries to unify with the Head of a Rule in the database

unifyWithHead (P query x) (P head y) = if (head == query && length(x) == length(y)) then unifyWithHead1 (P query x) (P head y)
									   else No
									 
unifyWithHead1 (P query []) (P head []) = Yes []
unifyWithHead1 (P query ((Cons constant1):xs)) (P head ((Cons constant2):ys)) = if (constant1 == constant2)
																				then unifyWithHead1 (P query xs) (P head ys)
																				else No
unifyWithHead1 (P query ((Var var1):xs)) (P head ((Cons constant1):ys)) = if unifyWithHead1 (P query xs) (P head ys) == No then No
																		  else Yes ((Var var1, Cons constant1):nextList)
																		where Yes nextList = unifyWithHead1 (P query xs) (P head ys)
unifyWithHead1 (P query ((Cons constant1):xs)) (P head ((Var var1):ys)) = if unifyWithHead1 (P query xs) (P head ys) == No then No
																		  else Yes ((Var var1, Cons constant1):nextList)
																		where Yes nextList = unifyWithHead1 (P query xs) (P head ys)
unifyWithHead1 (P query ((Var var1):xs)) (P head ((Var var2):ys)) = if unifyWithHead1 (P query xs) (P head ys) == No then No
																	else Yes ((Var var2, Var var1):nextList)
																  where Yes nextList = unifyWithHead1 (P query xs) (P head ys)

-- remove All No Solutions and Var to Var bindings, used in AllSolutions at the end

removeNoes [] = []
removeNoes (x:xs) = if x == No then removeNoes xs
				  	else (removeVarToVarBinding(x)):(removeNoes xs)

-- remove All Var to Var Bindings in a given Yes Solution

removeVarToVarBinding (Yes bindings) = Yes (removeVarToVarBinding1 bindings)

removeVarToVarBinding1 ((Var a, Cons b):xs) = (Var a, Cons b):removeVarToVarBinding1 xs
removeVarToVarBinding1 ((Var a, Var b):xs) = removeVarToVarBinding1 xs
removeVarToVarBinding1 [] = []

-- finds all Solutions to the given query in the database

allSolutions (P query x) kb = removeNoes (allSolutions1 (P query x) kb kb)

allSolutions1 (P query x) [] kb = []
allSolutions1 (P query terms1) ((P head terms2, body):ys) kb = if (body == []) then headSol : (allSolutions1 (P query terms1) ys kb)
														 	   else if (headSol == No) then (allSolutions1 (P query terms1) ys kb)
															   else (addBindingsToSols (consBindingsWhereVarInQuery headSol terms1) (combineAllSols (allAllSolutions (applySolSubInBody headSol body) kb) ) )
														 			++ (allSolutions1 (P query terms1) ys kb)
															 where headSol = unifyWithHead (P query terms1) (P head terms2)

-- finds all Solutions to multiple queries given in a List (used to find all the Solutions of the queries after subbing in the Body of a Rule)

allAllSolutions [] kb = []
allAllSolutions (x:xs) kb = (allSolutions x kb):(allAllSolutions xs kb)

-- Checks if the Variable of a Binding to Constant of the given Solution is in the terms of the Query and returns all such Variables

consBindingsWhereVarInQuery (Yes list) terms = consBindingsWhereVarInQuery1 list terms
consBindingsWhereVarInQuery No terms = []

consBindingsWhereVarInQuery1 [] terms = []
consBindingsWhereVarInQuery1 ((Var a, Cons b):xs) terms = if elem (Var a) terms then (Var a, Cons b):(consBindingsWhereVarInQuery1 xs terms)
														  else consBindingsWhereVarInQuery1 xs terms
consBindingsWhereVarInQuery1 ((Var a, Var b):xs) terms = consBindingsWhereVarInQuery1 xs terms

-- adds the given Bindings to the given List of Solutions

addBindingsToSols bindings [] = []
addBindingsToSols bindings ((Yes x):xs)  = (Yes (x ++ bindings)):(addBindingsToSols bindings xs)
addBindingsToSols bindings (No:xs)  = No:(addBindingsToSols bindings xs)