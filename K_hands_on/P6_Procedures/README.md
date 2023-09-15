## 6. Procedures

In this exercise, we take the previous exercise and extend the language with procedures 
and procedure calls.

1. Create another copy of control-flow.k` and rename it as `procedures.k` in `src/`.
    ```shell
    cp src/control-flow.k src/procedures.k
    ```
    and change all occurrences of `CONTROL-FLOW` with `PROCEDURES`.


2. Extend `Stmt` syntax to include `return` statement and `def` statment for defining function:
    ```k
    module PROCEDURES-SYNTAX
        ...

        // Statements
        syntax Stmt ::= 
          Id "=" IExp ";"                      [strict(2)] // Assignment
        | Stmt Stmt                            [left]      // Sequence  
        | Block                                            // Block
        | "if" "(" BExp ")" Block "else" Block [strict(1)] // If conditional
        | "while" "(" BExp ")" Block                       // While loop
        | "return" IExp ";"                    [seqstrict] // Return statement
        | "def" Id "(" Ids ")" Block                       // Function definition

        syntax Block ::=
          "{" Stmt "}"                                   // Block statement
        | "{"      "}"                                   // Empty block
        
    endmodule
    ```

    **Key point/s:**
    - `Ids`: a comma-separated list of identifiers, which we will define in the next step
    - `"return" IExp ";"`: E.g., `return x + y ;`
    - `"def" Id "(" Ids ")" Block`: E.g., `def sum(x, y) { return x + y ; }`


3. Add syntaxes of comma-separated lists of `Bot` (to represent empty list), `Id`, `Int` and `Exp` in the `PROCEDURES-SYNTAX` module.
    ```k
    module PROCEDURES-SYNTAX
        ...

        // "Bottom" subsort (empty set)
        syntax Bot
        // List of Bot (List of empty set, i.e., empty list)
        syntax Bots ::= List{Bot, ","} [klabel(Exps)]
        // List of Int
        syntax Ints ::= List{Int, ","} [klabel(Exps)]
                      | Bots
        // List of Ids
        syntax Ids  ::= List{Id, ","}  [klabel(Exps)]
                      | Bots
        // List of Exps
        syntax Exps ::= List{Exp, ","} [klabel(Exps), seqstrict]
                      | Ids | Ints
        
        ...
    endmodule
    ```

    **Key point/s:**
    - `[klabel(Exps)]`: Label the associated syntax as `Exps`


4. Add `Ints` as a subsort of `KResult` (for evaluation) and `Id "(" Exps ")"` as a subsort of `IExp` (for `return IExp ;`).
    ```k
    module PROCEDURES-SYNTAX
        ...

        // Signal when expression evaluation should stop
        syntax KResult ::= Int | Bool | Ints

        ...

        // Integer arithmetic syntax
        syntax IExp ::= 
            "(" IExp ")" [bracket]   
        > left:                       // left: indicates left associativity 
            IExp "^" IExp [seqstrict] // and > indicates lower priority of below productions
        > left:                   
            IExp "*" IExp [seqstrict]
        | IExp "/" IExp [seqstrict]
        > left:
            IExp "+" IExp [seqstrict]  
        | IExp "-" IExp [seqstrict]
        | Id "(" Exps ")" [strict(2)]
    
        ...
    
    endmodule
    ``` 


5. Import the K-Builtin module `LIST` under the `PROCEDURES` module and extend the `configuration` to include function 
store and operation stack:
    ```k
    module PROCEDURES
        imports INT
        imports BOOL
        imports LIST
        imports MAP
        imports PROCEDURES-SYNTAX 

        configuration
            // K cell, containing the statement to be evaluated
            <k> $PGM:Stmt </k>
            // Memory store, modelled as a K map
            <mem> .Map </mem>
            // Function store, modelled as a K map
            <funcs> .Map </funcs>
            // Operation stack, modelled as a K list
            <stack> .List </stack>

        ...
    endmodule
    ```


6. Add the following new `def FNAME ( ARGS ) { BODY }` and `return` rewrite rules:
    ```k
    module PROCEDURES
        ...

       // rule for defining function
        rule <k> def FNAME ( ARGS ) BODY => . ... </k>
            <funcs> FS => FS [ FNAME <- def FNAME ( ARGS ) BODY ] </funcs>

        // make binding between IS:Ints and ARGS when FNAME is called 
        rule <k> FNAME ( IS:Ints ) ~> CONT => #makeBindings(ARGS, IS) ~> BODY </k>
            <funcs> ... FNAME |-> def FNAME ( ARGS ) BODY ... </funcs>
            <mem> STORE => .Map </mem>
            <stack> .List => ListItem(state(CONT, STORE)) ... </stack>

        // rule for return I:Int when the program has not ended
        rule <k> return I:Int ; ~> _ => I ~> CONT </k>
            <stack> ListItem(state(CONT, STORE)) => .List ... </stack>
            <mem> _ => STORE </mem>

        // rule for return I:Int when the program has ended
        rule <k> return I:Int ; ~> . => I </k>
            <stack> .List </stack>

        // syntax for #makeBindings(Ids, Ints) and state(K, Map)
        syntax KItem ::= #makeBindings(Ids, Ints)
                        | state(continuation: K, store: Map)

        // rules for #makeBindings(Ids, Ints)
        rule <k> #makeBindings(.Ids, .Ints) => . ... </k>
        rule <k> #makeBindings((I:Id, IDS => IDS), (IN:Int, INTS => INTS)) ... </k>
            <mem> STORE => STORE [ I <- IN ] </mem>
        
        ...
    endmodule
    ```


7. Compile `procedure.k` with `--backend haskell` (for proofs later) and test it with `tests/6.procedures-test*`:
    ```shell
    krun tests/6.procedures-test1
    krun tests/6.procedures-test2
    ```


8. Create the following `sum-spec.k` file under `src/` and run `kprove src/sum-spec.k --debugger`.
    ```k
    requires "procedures.k"
    requires "domains.md"

    module SUM-SPEC-SYNTAX
        imports PROCEDURES-SYNTAX

        syntax Id ::= "$n" [token] | "$s" [token] | "$sum" [token]
    endmodule

    module VERIFICATION
        imports K-EQUAL
        imports SUM-SPEC-SYNTAX
        imports PROCEDURES

        rule ((K |->  V) _M) [ K' ] => V         requires K  ==K K' [simplification]
        rule ((K |-> _V)  M) [ K' ] => M [ K' ]  requires K =/=K K' [simplification]

        rule ((K |-> _V) M) [ K' <- V' ] => (K |-> V') M               requires K  ==K K' [simplification]
        rule ((K |->  V) M) [ K' <- V' ] => (K |-> V) (M [ K' <- V' ]) requires K =/=K K' [simplification]
    endmodule

    module SUM-SPEC
        imports VERIFICATION

        claim <k> while ( 0 < NID ) {
                    SID = SID + NID ;
                    NID = NID - 1 ;
                }
            => . ... </k>
            <mem> SID |-> (S:Int => S +Int ((N +Int 1) *Int N /Int 2))
                    NID |-> (N:Int => 0)
            </mem>
        requires N >=Int 0
        andBool S >=Int 0

        claim <k> def $sum($n, .Ids) {
                    $s = 0 ;
                    while (0 < $n) {
                    $s = $s + $n ;
                    $n = $n - 1 ;
                    }
                    return $s ;
                }
                return $sum(N:Int, .Ints) ;
            => return (N +Int 1) *Int N /Int 2 ;
            </k>
            <funcs> .Map => ?_ </funcs>
            <mem> .Map => ?_ </mem>
            <stack> .List </stack>
        requires N >=Int 0

    endmodule
    ```


9. There are 2 claims in this file. The 1st one (claim 0) is a lemma which is essential for proving the main theorem which is 
the 2nd claim (claim 1). Try proving both claims in Kore Repl. Can you find out the instance where the 2nd claim uses the 1st claim as 
part of the proof? What if you remove the 1st claim (i.e., commenting it), can you still prove the 2nd claim? 
[Hint: Use `stepf` to complete both proofs and use `graph expanded` for the 2nd claim.]
