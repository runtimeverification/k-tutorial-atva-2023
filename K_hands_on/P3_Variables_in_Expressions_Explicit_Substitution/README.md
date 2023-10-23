## P3. Variables in Expressions, Explicit Substitution

In this exercise, we take the expression calculator of the previous exercise and 
extend the syntax of integer expressions with variables. We want to evaluate programs 
such as `((a / b) * c) - d` as seen in `tests/3.subst-test3` (given some explicit substitutions).

1. Create another copy of `calc-bool.k` and rename it as `subst.k` in `src/`.
    ```shell
    cp src/calc-bool.k src/subst.k
    ```

2. Rename the `CALC-BOOL-SYNTAX` module name to `SUBST-SYNTAX` and expand `Exp` to include `IExp` and `BExp`
where `IExp ::= Int | Id` (`Id` is the K built-in sort for identifiers/variables) and `BExp ::= Bool`:
    ```k
    module SUBST-SYNTAX
        imports INT-SYNTAX  // Int is the K built-in integer sort
        imports BOOL-SYNTAX // Bool is the K built-in Boolean sort
        imports ID          // Id is the K built-in sort for identifiers (variables)imports ID-SYNTAX

        // Expressions are either integers or Booleans
        syntax Exp ::= IExp | BExp

        // An integer expression is either an integer value or a variable identifier
        syntax IExp ::= Int | Id 
        // Integer arithmetic syntax (replace all occurrences of `Int` to `IExp`)
        ...

        // A Boolean expression is either a Boolean value
        syntax BExp ::= Bool
        // Integer comparison syntax (replace all occurrences of `Int` to `IExp`)
        syntax BExp ::= 
            "(" BExp ")" [bracket]
        ...

        // Propositional connective syntax (replace all occurrences of `Bool` to `BExp`)
        ...
    endmodule
    ```

    **Key points**
    - Change `syntax Exp ::= Int | Bool` to `syntax Exp ::= IExp | BExp`
    - Add `syntax IExp ::= Int | Id`
    - Replace appropriate occurrences of `Int` to `IExp`
    - Add `syntax BExp ::= Bool`
    - Replace appropriate occurrences of `Bool` to `BExp`
  
   Compile this new `subst.k` and test it with the tests for `calc-bool.k`. You should be able to run all of them smoothly.


3. Rename the `CALC-BOOL` module name to `SUBST`, import `MAP` module and define a new `<mem> ... </mem>` cell under `configuration` 
which works as a memory storage, modelled as a K map, i.e., explicit mapping of `a`, `b`, `c` and `d` 
(we will see how to make use of this cell in the next step):
    ```k
    module SUBST
        imports INT
        imports BOOL
        imports MAP
        imports SUBST-SYNTAX 

    configuration
        // K cell, containing the expression to be evaluated
        <k> $PGM:Exp </k>
        // Variable store, modelled as a K map
        <mem> 
            #token("a", "Id") |-> 16
            #token("b", "Id") |-> 9
            #token("c", "Id") |-> 4
            #token("d", "Id") |-> 2
        </mem>
    ...
    endmodule
    ```

    **Key points**
    - `#token("<variable>", "Id")`: To define `variable` as an `Id`
    - `<LHS> |-> <RHS>`: To define mapping from `<LHS>` to `<RHS>` (hence, the `imports MAP`)


4. Remove the `[function]` from each of the integer arithmetic syntax and 
replace the section "Integer arithmetic semantics" from `calc-bool.k` with the following:
    ```k
    module SUBST
        ...
        // Syntax of `substI`: Integer expression substitution 
        syntax Int ::= substI ( IExp , Map ) [function]

        // Integer expression evaluation via explicit substitution 
        rule 
        <k> IE:IExp => substI(IE, STORE) </k>
        <mem> STORE </mem>
        requires notBool isInt(IE) // so that it will not go into a loop
    
        // Base case: integer values evaluate to themselves
        rule substI(I:Int, _SUBST) => I

        // Base case: identifiers evaluate to their value in the store
        rule substI(I:Id, SUBST) => {SUBST [ I ]}:>Int

        // Inductive cases 
        rule substI(I1 + I2, SUBST) => substI(I1, SUBST) +Int substI(I2, SUBST)
        rule substI(I1 - I2, SUBST) => substI(I1, SUBST) -Int substI(I2, SUBST)
        rule substI(I1 * I2, SUBST) => substI(I1, SUBST) *Int substI(I2, SUBST)
        rule substI(I1 / I2, SUBST) => substI(I1, SUBST) /Int substI(I2, SUBST)
        rule substI(I1 ^ I2, SUBST) => substI(I1, SUBST) ^Int substI(I2, SUBST)
        ...
    endmodule
    ```

    **Key points**

    - `[function]` needs to be removed as each of the arithmetic syntax works as a constructor, 
    which its arguments will be further evaluated through `substI`.
    - `syntax Int ::= substI ( IExp , Map ) [function]`: Syntax of `substI` function
    - `rule <k> IE:IExp => substI(IE, STORE) ... </k> <mem> STORE </mem>`: 
    When `IExp` is passed to the K cell, `rewrite to substI(IE, STORE)` while identifying the second argument 
    of `substI`, `STORE`, as the STORE of `Map` sort in `<mem> ... </mem>.
    - `requires notBool isInt(IE)`: To make sure the rule will not go into a loop
    - `rule substI(I:Int, _SUBST) => I`: Direct substitution when `substI` is applied to `I:Int`
    - `rule substI(I:Id, SUBST) => {SUBST [ I ]}:>Int`: Retrieve mapping value when `substI` is applied to `I:Id`
    - `rule substI(I1 + I2, SUBST) => substI(I1, SUBST) +Int substI(I2, SUBST)`, etc:
        How `substI` is to be evaluated for integer arithmetic syntax.

   Compile this modified `subst.k` and test it with the `tests/3.subst-test3`. You should be able to run all of them smoothly.


5. However, if you try to test the current state of `subst.k`, you will run into error when testing with `tests/3.subst-test1` 
as K does not know how to do with `>=`. Next, repeat the procedure you did for `substI` for `substB` 
(you can refer to `P3_Variables_in_Expressions_Explicit_Substitution/subst.k` for the completed version of this file):
    ```k
    module SUBST
        ...

        // Inductive cases
        ...

        // NOTE: Replace the "Integer comparison semantics" and "Propositional connective semantics"
        // sections with the following:

        // Boolean expression substitution
        syntax Bool ::= substB ( BExp , Map ) [function]

        // Boolean expression evaluation via explicit substitution 
        rule 
            <k> BE:BExp => substB(BE, STORE) </k>
            <mem> STORE </mem>
            requires notBool isBool(BE) // so that it will not go into a loop

        // Base case: Boolean values evaluate to themselves
        rule substB(B:Bool , _SUBST) => B

        // Inductive cases 
        rule substB(I1 <= I2, SUBST) => substI(I1, SUBST)  <=Int substI(I2, SUBST)
        rule substB(I1  < I2, SUBST) => substI(I1, SUBST)   <Int substI(I2, SUBST)
        rule substB(I1 >= I2, SUBST) => substI(I1, SUBST)  >=Int substI(I2, SUBST)
        rule substB(I1  > I2, SUBST) => substI(I1, SUBST)   >Int substI(I2, SUBST)
        rule substB(I1 == I2, SUBST) => substI(I1, SUBST)  ==Int substI(I2, SUBST)
        rule substB(I1 != I2, SUBST) => substI(I1, SUBST) =/=Int substI(I2, SUBST)
        rule substB(B1 && B2, SUBST) => substB(B1, SUBST) andBool substB(B2, SUBST)
        rule substB(B1 || B2, SUBST) => substB(B1, SUBST)  orBool substB(B2, SUBST)
    endmodule
    ```


6. Compile the latest version of `subst.k` and test it with the 3 tests for `subst`:
    ```shell
    krun tests/3.subst-test1
    krun tests/3.subst-test2
    krun tests/3.subst-test3
    ```
