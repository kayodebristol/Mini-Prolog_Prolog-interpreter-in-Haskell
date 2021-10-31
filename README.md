# Mini-Prolog
An interpreter for a mini version of the Prolog language written using Haskell.

The interpreter is able to answer queries with a special notation.
In order to answer a query, the rules of the knowledge base are explored one after the other, in order. Once a query unifies with a fact
it succeeds. When a query unifies with the head of a rule, the goals specified in the body of that rule have to be proven in
order for the query to succeed.

The following restrictions are made about our mini-Prolog language for simplicity:
* A term will be either a variable or a constant. Our language will not include function symbols with
arity bigger than zero.
* Every fact or rule in the given knowledge base will have in its head an argument list of constants
and/or distinct variable names.
* No variable will appear in the body of a rule unless it appears in its head.
* No body of any rule will contain negation or recursion.
* The list of arguments in a given query will consist of constants and/or distinct variable names.
* All variables appearing in queries can be considered fresh variables for the rules in the knowledge base.
* All variables that appear are of the form of a single uppercase letter.

The following data types were defined:
* Term: A term is either a constant or a variable. The name of the term is a String.
* Predicate: A predicate is represented by its name and list of arguments. The arguments are terms.
* Goals: A (possibly empty) list of goal predicates. For simplicity, only goals which are logically
ANDed were implemented.
* Rule: A rule consists of a head and a body. The head is a simple Predicate while the body
is of type Goals. Note that a fact can be represented as a rule with an empty body.
* Solution: A solution is either No (failure) or Yes (success). In case of success, the solution
also includes the list of variable substitutions required.

The following functions were implemented:
* unifyWithHead which evaluates the solution for unifying two predicates.
The input to this function is as follows:
  * A predicate representing the query or the goal.
  * A predicate representing the head of a rule in the knowledge base.
  * The current solution which indicates which variables are bound and their substituted values.
The output of this function will be of type Solution. Hence, the new solution will be either:
  * No if the unification is not possible.
  * Yes and the (updated) list of variable substitutions.
* applySolSubInBody. The input to this function will be a success Solution and a body of type Goals.
The function should evaluate the new body in which the variable substitions of the solution are applied.
* allSolutions. The input to this function will be a predicate representing a query and a list of rules
representing the knowledge base. The function should evaluate the query according to the given knowledge
base. The function should output a list of type Solution representing all possible solutions to the given
query. If the query fails (has no solutions at all), the output will be an empty list.

## Using the implemented functions
* Install Haskell Platform on your system.
* Run the console scripts "ghci - Load files in this directory.bat" if you're using Windows or "ghci - Load files in this directory.sh"
if you're using Linux.
  * These will just run ghci while setting the working directory to be the current directory, while disabling the warning
"Tab character found here, ... Please use spaces instead.". And they will also load the 2 modules
"MiniProlog" and "Main".
* Now to test the functions, you can try out the queries from "Queries.txt". For the 1st set of queries, the knowledge base (set of Prolog facts)
is already set in a variable "kb" (when loading the "Main" module), as they are quite long.
  * You can check what facts that "kb" stores by opening the file
"father_daughterFather.pl", or opening "Main.hs" to check what Haskell stores in the variable upon loading the module Main.
  * You can verify if your output is correct by checking the correct outputs in "Queries with solutions.txt".

## Notes
"father_daughterFather.pl" is a Prolog file that contains exactly the kb that corresponds to the kb in the 1st set of queries, and
"Prolog queries.txt" contains the same queries as the 1st set of queries but in the Prolog format, so you can test it out in 
Prolog to verify that the output of the Haskell mini-Prolog interpreter is correct.
