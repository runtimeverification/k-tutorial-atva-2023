## P4. Assignment Operator

In this exercise, we take the previous exercise and build a simple programming language 
on top of the expression evaluator, starting from a variable assignment command and command sequencing.
Thus, instead of having hard coded values in storage, we can update variables with new values 
and evaluate expressions in sequence of commands, e.g., `tests/4.assignment-test1`.

1. Create another copy of `subst.k` and rename it as `assignment.k` in `src/`.
    ```shell
    cp src/subst.k src/assignment.k
    ```
    and change all occurrences of `SUBST` with `ASSIGNMENT`.


2. Add in syntax of a statement, `Stmt`, at the end of the `ASSIGNMENT-SYNTAX` module, 
which is either an assignment or a (left-associative) sequence of statments.
    ```k
    module ASSIGNMENT-SYNTAX
        ...

        // A statement is
        syntax Stmt ::=  
              // either an assignment
              Id "=" IExp ";"
              // or a (left-associative) sequence of statements 
            | Stmt Stmt [left]

    endmodule  
    ```


3. Change `$PGM` sort from `Exp` to `Stmt` and the explicit map under `configuration` of `<mem> ... </mem>` 
to an empty map, `.Map`.
    ```k
    module ASSIGNMENT
        imports INT
        imports BOOL
        imports MAP
        imports ASSIGNMENT-SYNTAX 

        configuration
            // K cell, containing the statement to be evaluated
            <k> $PGM:Stmt </k>
            // Variable store, modelled as a K map
            <mem> 
                .Map // initially an empty map
            </mem>
        
        ...

    endmodule
    ```

4. Add the semantics of `Stmt` at the end of the `ASSIGNMENT` module.
    ```k
    module ASSIGNMENT
        imports INT
        imports BOOL
        imports MAP
        imports ASSIGNMENT-SYNTAX 

        ...

        // Assignment
        rule 
            <k> ID = IE ; => . ... </k>
            <mem> STORE => STORE [ ID <- substI(IE, STORE) ] </mem>

        // Sequencing
        rule 
            <k> S1:Stmt S2:Stmt => S1 ~> S2 ... </k>

    endmodule
    ```

    **Key point/s**

    - `~>`: Sequencing syntax in K, e.g., `S1 ~> S2` means evaluate `S1` first, followed by S2
    - `...`: Same as `~> REST`, e.g., `S1:Stmt S2:Stmt => S1 ~> S2 ...` <=> `(S1:Stmt S2:Stmt => S1 ~> S2) ...` 
    <=> `(S1:Stmt S2:Stmt => S1 ~> S2) ~> REST` <=> S1:Stmt S2:Stmt ~> REST => S1 ~> S2 ~> REST
    - `.` (period): End of evaluation (so that the K cell will stop or move to the next evaluation)

5. Compile the current version of `assignment.k` and test it with `tests/4.assignment-test1` and `tests/4.assignment-test2`:
    ```shell
    krun tests/4.assignment-test1
    krun tests/4.assignment-test2
    ```
    Note that you will not be able to run tests from previous exercise as the only `$PGM` recognized in K cell is `Stmt`. 
    To allow these tests to run, we can add `Exp` as part of the `Stmt` syntax (the semantic for expression statement 
    is taken care by the integer and boolean expression evaluation, which was done in previous exercise). We will leave this 
    as an exercise.
    

#### Step-by-step rewrite procedure

To see how the rewrite procedure is done in the K cell step-by-step, 
you can run `krun` with the `--depth N` option where N is a nonnegative integer.
Try running `krun tests/4.assignment-test2 --depth N` for `N = 0, 1, 2, ...`.


What we have done until now in this exercise is to do assignments with 
substitution-based semantics, i.e., through the functions `substI` and `substB`. 
Writing the substitution explicitly is tedious, and would not scale for larger 
languages. For this reason, K provides mechanisms that significantly automate 
this process by using the deterministic evaluation order or strictness-based 
semantics, i.e., through the use of `[seqstrict]` and `[strict]`.


6. Create another copy of `assignment.k` and rename it as `assignment-strict.k` in `src/`.
    ```shell
    cp src/assignment.k src/assignment-strict.k
    ```
    and change all occurrences of `ASSIGNMENT` with `ASSIGNMENT-STRICT`.


7. Annotate operators for both `IExp` and `BExp` under the `ASSIGNMENT-STRICT-SYNTAX` 
module with the `[seqstrict]` attribute, which, essentially, means that the sub-expressions 
of the given binary operators are to be evaluated deterministically, left-to-right:
    ```k
    module ASSIGNMENT-STRICT-SYNTAX
        imports INT-SYNTAX  // Int is the K built-in integer sort
        imports BOOL-SYNTAX // Bool is the K built-in Boolean sort
        imports ID          // Id is the K built-in sort for identifiers (variables)imports ID-SYNTAX

        // Expressions are either integers or Booleans
        syntax Exp ::= IExp | BExp

        // An integer expression is either an integer value or a variable identifier
        syntax IExp ::= Int | Id 
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

        // A Boolean expression is either a Boolean value
        syntax BExp ::= Bool
        // Integer comparison syntax
        syntax BExp ::= 
            "(" BExp ")" [bracket]
        | IExp "<=" IExp [seqstrict]
        | IExp "<"  IExp [seqstrict]
        | IExp ">=" IExp [seqstrict]
        | IExp ">"  IExp [seqstrict]
        | IExp "==" IExp [seqstrict]
        | IExp "!=" IExp [seqstrict]

        // Propositional connective syntax
        syntax BExp ::= 
          BExp "&&" BExp [seqstrict]
        | BExp "||" BExp [seqstrict]

        ...

    endmodule
    ```


8. Annotate `Id "=" IExp ";"` under the `Stmt` syntax with `[strict(2)]` to make 
the order of evaluation non-deterministic (in this case, we are only evaluating 
the 2-nd expression.
    ```k
    module ASSIGNMENT-STRICT-SYNTAX
        ...

        // A statement is
        syntax Stmt ::=  
            // either an assignment
            Id "=" IExp ";" [strict(2)]
            // or a (left-associative) sequence of statements 
          | Stmt Stmt [left]

    endmodule
    ```


9. Extend the `K` built-in `KResult` sort with `Int` and `Bool` as we also need to 
tell K that the evaluation should stop when the expression reach integer or boolean value.
    ```k
    module ASSIGNMENT-STRICT-SYNTAX
        imports INT-SYNTAX  // Int is the K built-in integer sort
        imports BOOL-SYNTAX // Bool is the K built-in Boolean sort
        imports ID          // Id is the K built-in sort for identifiers (variables)imports ID-SYNTAX

        // Signal when expression evaluation should stop
        syntax KResult ::= Int | Bool

        ...

    endmodule
    ```


10. Remove and modify the syntaxes and semantics of `substI` and `substB` accordingly 
as the semantics is substantially simplified in that there is no more substitution, 
and the expression evaluation is formulated straightforwardly:
    ```k
    module ASSIGNMENT-STRICT
        imports INT
        imports BOOL
        imports MAP
        imports ASSIGNMENT-STRICT-SYNTAX 

        configuration
            // K cell, containing the statement to be evaluated
            <k> $PGM:Stmt </k>
            // Variable store, modelled as a K map
            <mem> 
                .Map // initially an empty map
            </mem>    

        // Expression evaluation
        
        // Base case: Variables evaluate to their values in the store
        rule 
            <k> I:Id => STORE[I] ... </k>
            <mem> STORE </mem>

        // Arithmetic operators 
        rule <k> I1 + I2 => I1 +Int I2 ... </k>
        rule <k> I1 - I2 => I1 -Int I2 ... </k>
        rule <k> I1 * I2 => I1 *Int I2 ... </k>
        rule <k> I1 / I2 => I1 /Int I2 ... </k>
        rule <k> I1 ^ I2 => I1 ^Int I2 ... </k>

        // Comparison operators
        rule <k> I1 <= I2 => I1  <=Int I2 ... </k>
        rule <k> I1  < I2 => I1   <Int I2 ... </k>
        rule <k> I1 >= I2 => I1  >=Int I2 ... </k>
        rule <k> I1  > I2 => I1   >Int I2 ... </k>
        rule <k> I1 == I2 => I1  ==Int I2 ... </k>
        rule <k> I1 != I2 => I1 =/=Int I2 ... </k>

        // Propositional connectives
        rule <k> B1 && B2 => B1 andBool B2 ... </k>
        rule <k> B1 || B2 => B1  orBool B2 ... </k>

        // Assignment
        rule 
            <k> ID = I:Int ; => . ... </k>
            <mem> STORE => STORE [ ID <- I ] </mem>

        // Sequencing
        rule 
            <k> S1:Stmt S2:Stmt => S1 ~> S2 ... </k>

    endmodule
    ```

11. Compile `assignment-strict.k` and test it with `tests/4.assignment-test1` and/or 
`tests/4.assignment-test2`:
    ```shell
    krun tests/4.assignment-test1
    krun tests/4.assignment-test2
    ```


#### Understanding deterministic evaluation order/strictness-based semantics

To see how evaluation thorugh strictness-based semantics work, we can `krun`, 
say with `tests/4.assignment-test1`, with option `--depth N` as seen in the following steps:

12. For `krun tests/4.assignment-test1 --depth 4`, we have:
    ```shell
    <generatedTop>
        <k>
            z = x * y ; ~> .
        </k>
        <mem>
            x |-> 3
            y |-> 4
        </mem>
    </generatedTop>    
    ```
    At this point, we have the STORE cell with `x` and `y` are mapped to 3 and 4 respectively 
    and `z = x * y ; ~> .` is about to be rewritten in the K cell through the strictness semantics 
    defined previously, i.e., `Id "=" IExp ";" [strict(2)]`.

13. If we increase the `--depth` by 1, i.e., `krun tests/4.assignment-test1 --depth 5`, we have:
    ```shell
    <generatedTop>
        <k>
            x * y ~> #freezer_=_;_ASSIGNMENT-STRICT-SYNTAX_Stmt_Id_IExp1_ ( z ~> . ) ~> .
        </k>
        <mem>
            x |-> 3
            y |-> 4
        </mem>
    </generatedTop>
    ```
    We can think of the evaluation for `Id "=" IExp ";" [strict(2)]` you just see in the K cell as a "heating" rewrite rule  
    defined in the K Builtin:
    ```k
    rule <k> I:Id = IE:IExp => IE ~> I = [] ... </k> requires notBool isKResult(IE) // heating (of IE to get placeholder [])
    ```


14. For each evaluation through the strictness semantics, every "heating" rule comes with a "cooling" rule. 
Skip `--depth N` for `N = 6, ..., 11` (these steps show you how the "heating" and "cooling" rules applied 
accordingly for `IExp "*" IExp [seqstrict]`, which will be left as an exercise) and run `N = 12`, i.e., 
`krun tests/4.assignment-test1 --depth 12`.
    ```shell
    <generatedTop>
        <k>
            12 ~> #freezer_=_;_ASSIGNMENT-STRICT-SYNTAX_Stmt_Id_IExp1_ ( z ~> . ) ~> .
        </k>
        <mem>
            x |-> 3
            y |-> 4
        </mem>
    </generatedTop>    
    ```
    At this point, `x * y` has been evaluated to 12 (through `--depth` 6 to 11) and is waiting to be "cooled".


15. Run `krun tests/4.assignment-test1 --depth 13` and we have:
    ```shell
    <generatedTop>
        <k>
            z = 12 ; ~> .
        </k>
        <mem>
            x |-> 3
            y |-> 4
        </mem>
    </generatedTop>
    ```
    The "cooling" rewrite rule defined in the K builtin that was used from `--depth` 12 to 13 is as follows:
    ```k
    rule <k> IE:IExp ~> I = [] => I = IE ... </k> requires isKResult(IE) // cooling (of [] to be replaced by IE)
    ```