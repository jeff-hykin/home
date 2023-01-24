
My definitions (not necessarily true in general)

Both "a" and "-a" are terms
"a" is a symbol
"-a" is not a symbol
Clauses are basically lists of terms

True in general:
A clause is false if ALL the terms are false
A clause is true if ONE of the terms are true
A clause is a unit clause if there is 1 unknown term, and all other terms are false


DPLL
Arguments: clauses, model

for clauses
- if ONE clause is false, then return Null
- if ALL clauses are true, then return model;
- if clause is unknown: continue

# unit heuristic
for each clause
- if it's a unit clause
- get the term from the clause
- get the symbol from the term
- newModel = copy(oldModel)
- newModel[symbol] = true
- return DPLL(clauses, newModel)

# fallback option
symbol <- get_first_unassigned_symbol(model)
# attempt true
newModel <- copy(oldModel)
newModel[symbol] <- true
output = DPLL(clauses, newModel)
If output is null
   # attempt false
   newModel <- copy(oldModel)
   new
   newModel[symbol] <- false
   output <- DPLL(clauses, newModel)

return output