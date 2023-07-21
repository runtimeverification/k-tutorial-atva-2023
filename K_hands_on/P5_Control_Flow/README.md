## P5. Control Flow

In this exercise, we take the previous exercise and extend the syntax of commands with blocks of commands 
and some control flow constructs, such as the if-else conditional statement and the while loop. Furthermore, 
we will see how we can use K to prove properties of the calculator programming language that we have created 
up till this point. 


1. Create another copy of `assignment-strict.k` and rename it as `control-flow.k` in `src/`.
    ```shell
    cp src/assignment-strict.k src/control-flow.k
    ```
    and change all occurrences of `ASSIGNMENT-STRICT` with `CONTROL-FLOW`.


2. Modify the `Stmt` syntax as follows to include a new syntax `Block`, if-else condition and while loop:
    ```k
    module CONTROL-FLOW-SYNTAX
        ...

        // Statements
        syntax Stmt ::= 
          Id "=" IExp ";"                      [strict(2)] // Assignment
        | Stmt Stmt                            [left]      // Sequence  
        | Block                                            // Block
        | "if" "(" BExp ")" Block "else" Block [strict(1)] // If conditional
        | "while" "(" BExp ")" Block                       // While loop

        syntax Block ::=
          "{" Stmt "}"                                   // Block statement
        | "{"      "}"                                   // Empty block

    endmodule
    ```


3. Add the semantics for the 4 new syntax of `Stmt`:
    ```k
    module CONTROL-FLOW
        imports INT
        imports BOOL    
        imports MAP
        imports CONTROL-FLOW-SYNTAX  

        ...   

        // Assignment
        rule 
            <k> ID = I:Int ; => . ... </k>
            <mem> STORE => STORE [ ID <- I ] </mem>

        // Sequencing
        rule 
            <k> S1:Stmt S2:Stmt => S1 ~> S2 ... </k>

        // Block statements
        rule <k> { S } => S ... </k>
        rule <k> {   } => . ... </k>

        // If conditional
        rule <k> if (true)   THEN else _ELSE => THEN ... </k>
        rule <k> if (false) _THEN else  ELSE => ELSE ... </k>

        // While loop
        rule <k> while ( BE ) BODY => if ( BE ) { BODY while ( BE ) BODY } else { } ... </k>

    endmodule
    ```


4. Compile `control-flow.k` and test it with `tests/5.control-flow-test*`:
    ```shell
    krun tests/5.control-flow-test1
    krun tests/5.control-flow-test2
    krun tests/5.control-flow-test3
    ```


5. Now we are ready to prove some properties! Create a new file, `control-flow-spec.k`, in `src/` with the following content:
    ```k
    requires "control-flow.k"
    requires "domains.md"

    // ID variables syntax
    module CONTROL-FLOW-SPEC-SYNTAX
        imports CONTROL-FLOW-SYNTAX

        syntax Id ::= "$a" [token]
                    | "$b" [token]
                    | "$c" [token]
                    | "$s" [token]
                    | "$n" [token]
    endmodule

    // Module for verification rules/lemmas
    module VERIFICATION
        imports CONTROL-FLOW-SPEC-SYNTAX
        imports CONTROL-FLOW

    endmodule

    // Module for all claims to be proven
    module CONTROL-FLOW-SPEC
        imports VERIFICATION

        claim <k> 3 + 4 => 7 </k>

    endmodule
    ```


6. Compile `src/control-flow.k` with `--backend haskell` (compiling with haskell backend is required for proofs). 
Then `kprove control-flow-spec.k`, which K will prove the only `claim <k> 3 + 4 => 7 </k>` that we have added 
(note that for claims, i.e., property yet to be proven, we use the syntax `claim`). You will expect a `#Top` output 
which signifies the claim has been verified by the proof engine of K.
    ```shell
    kprove src/control-flow-spec.k
    ```


7. What if the claim cannot be proven? Change the RHS of the claim from 7 to 8 and run `kprove src/control-flow-spec.k`. 
You will see the following output:
    ```shell
    kore-exec: [297002] Warning (WarnStuckClaimState):
        The configuration's term doesn't unify with the destination's term and the configuration cannot be rewritten further. ...
    Context:
        (InfoReachability) while checking the implication
    <generatedTop>
        <k>
            7 ~> .
        </k>
        <mem>
            _Gen2
        </mem>
    </generatedTop>
    [Error] Prover: backend terminated because the configuration cannot be
    rewritten further. See output for more details.
    ```
    The `<generatedTop>` cell shows the last state that the proof stuck on. Although there is not much details provided, 
    it is easy to see that in this example, the final state in K cell, 7, cannot be unified with 8 in the amended claim.


8. Add the following claim in the `CONTROL-FLOW-SPEC` module and run `kprove src/control-flow-spec.k`:
    ```k
    claim <k> if ( 3 < 4 ) {
                $c = 1 ;
              } else {
                $c = 2 ;
              }
           => . ... </k>
          <mem> STORE => STORE [ $c <- 1 ] </mem>
    ```
    You should expect `#Top` as output.


9. Try changing the 4 in this newly added claim to 2 and run `kprove src/control-flow-spec.k`. You should expect the following 
output:
    ```shell
    kore-exec: [325694] Warning (WarnStuckClaimState):
        The configuration's term unifies with the destination's term, but the implication check between the conditions has failed. ...
    Context:
        (InfoReachability) while checking the implication
    #Not ( {
        STORE [ $c <- 1 ]
    #Equals
        STORE [ $c <- 2 ]
    } )
    #And
    <generatedTop>
        <k>
            _DotVar1
        </k>
        <mem>
            STORE [ $c <- 2 ]
        </mem>
    </generatedTop>
    [Error] Prover: backend terminated because the configuration cannot be
    rewritten further. See output for more details.
    ```
    Based on the output, can you trace why the proof failed?


10. Add the following claim in the `CONTROL-FLOW-SPEC` module and run `kprove src/control-flow-spec.k`:
    ```k
    claim <k> $a = A:Int ; $b = B:Int ;
              if (A < B) {
                $c = B ;
              } else {
                $c = A ;
              }
           => . ... </k>
          <mem> STORE => STORE [ $a <- A ] [ $b <- B ] [ $c <- ?C:Int ] </mem>
      ensures A <=Int ?C
      andBool B <=Int ?C    
    ```
    In this claim, instead of having concrete integers such 3 and 4 like the previous claim, 
    we are using symbolic integer `A` and `B`. The program in this claim essentially describes a max function between 
    2 (symbolic) integers but we are not actually proving the program is a max function, we are simply proving that 
    the final value that `$c` maps to is A <=Int ?C andBool B <=Int ?C`. 
    
    **Key point/s:**
    - `?C`: there exists a C
    - `ensures`: Whenever we want to constraint a existential symbolic variable/expression, we use `ensures` 
    (we use `requires` for non-existential variable like we have seen previously).


11. Oh no! The proof failed but why? Lets look at the output (only the important parts will be displayed below): 
    ```shell
    kore-exec: [381028] Warning (WarnUnexploredBranches):
        1 branches were still unexplored when the action failed.
    #Not ( #Exists ?C . {
        STORE [ $a <- A:Int ] [ $b <- B:Int ] [ $c <- ?C:Int ]
        #Equals
        STORE [ $a <- A:Int ] [ $b <- B:Int ] [ $c <- B:Int ]
        }
    #And
        {
        true
        #Equals
        A <=Int ?C
        }
    #And
        {
        true
        #Equals
        B <=Int ?C
        } )
    #And
    <generatedTop>
        <k>
            _DotVar1
        </k>
        <mem>
            STORE [ $a <- A:Int ] [ $b <- B:Int ] [ $c <- B:Int ]
        </mem>
    </generatedTop>
    #And
    {
        true
    #Equals
        A <Int B
    }
    ```  

    **Key point/s:**
    - We are at the branch where `true #Equals A <Int B` and there is 1 branch still unexplored, i.e., 
    `true #Equals A <Int B`.
    - The STORE cell at the final GeneratedTop cell shows that `STORE [ $a <- A:Int ] [ $b <- B:Int ] [ $c <- B:Int ]`.
    - But K could not be evaluate the following:
    ```shell
    #Not ( #Exists ?C . {
        STORE [ $a <- A:Int ] [ $b <- B:Int ] [ $c <- ?C:Int ]
        #Equals
        STORE [ $a <- A:Int ] [ $b <- B:Int ] [ $c <- B:Int ]
        }
    ```
    - The reason is that there is no rule that tell K that if `$v <- V` and `v <- V'`, then `V = V'`.


12. Just like whenever you prove a theorem, sometimes you need a "smaller" lemma to help you with the proof. 
Add the following rule in the `VERIFICATION` module and  `kprove src/control-flow-spec.k` again: 
    ```k
    rule { MAP [ K <- V' ] #Equals MAP [ K <- V ] } => { V' #Equals V } [simplification]
    ```
    Did you get a `#Top` output?


13. For completeness sake, we will add some new rules for a new function, `maxInt` and a new claim 
to prove that the program that we just went through is indeed a max function. Add the following rules 
in the `VERIFICATION` module:
    ```k
    rule maxInt(X, Y) => Y requires         X <Int Y [simplification]
    rule maxInt(X, Y) => X requires notBool X <Int Y [simplification]
    ```
    And the following claim in `CONTROL-FLOW-SPEC` and `kprove src/control-flow-spec.k`:
    ```k
    claim <k> $a = A:Int ; $b = B:Int ;
              if (A < B) {
                $c = B ;
              } else {
                $c = A ;
              }
           => . ... </k>
          <mem> STORE => STORE [ $a <- A ] [ $b <- B ] [ $c <- maxInt(A, B) ] </mem>
    ```


14. To end off this part of the tutorial, we will try to prove a specification with the `while` loop. 
Add the following `claim` in the `CONTROL-FLOW-SPEC` module:
    ```k
    claim 
      <k> 
          while ( 0 < $n ) {
                $s = $s + $n ;
                $n = $n - 1 ;
            } => . ... 
      </k>
      <mem> 
          $s |-> (S:Int => S +Int ((N +Int 1) *Int N /Int 2))
          $n |-> (N:Int => 0)
      </mem>
      requires N >=Int 0
    ```


15. Instead of just running `kprove src/control-flow-spec.k`, we will try it with `--debugger` option 
where we will got into our `Kore Repl` and prove the claim interactively. This is especially useful for 
failed proof.
    ```shell
    kprove src/control-flow-spec.k --debugger
    ```


16. Run `proof-status` to check on the proof status of all the claim in the file. Run `prove 4` 
to select the 4th `claim` which is the `while` loop claim.
    ```shell
    Kore (0)> proof-status
    Current proof status: 
        claim 4: NotStarted
        claim 3: NotStarted
        claim 2: NotStarted 
        claim 1: NotStarted
        claim 0: InProgress [0] 
    Kore (0)> prove 4 
    Switched to proving claim 4
    ```


17. Run `konfig` to see the configuration at the current proof step (we are still at proof step/node 0).
    ```shell
    Kore (0)> konfig
    Config at node 0 is:

    <generatedTop>
        <k>
            while ( 0 < $n ) { $s = $s + $n ; $n = $n - 1 ; } ~> _DotVar1:K
        </k>
        <mem>
            $n |-> N:Int
            $s |-> S:Int
        </mem>
    </generatedTop>
    #And
        {
            true
        #Equals
            N:Int >=Int 0
        }
    ```


18. There are several commands for you to step through the proof tree. 
    - `step N` will step `N` steps down the proof tree and stops when there is branching in the tree.
    - `stepf N` will step `N` steps down the proof tree but will not stop even when there is branching in the tree.
    ```shell
    Kore (0)> step
    Kore (1)> konfig
    Config at node 1 is:

    <generatedTop>
        <k>
            if ( 0 < $n ) { { $s = $s + $n ; $n = $n - 1 ; } while ( 0 < $n ) { $s = $s + $n ; $n = $n - 1 ; } } else { } ~> _DotVar1:K
        </k>
        <mem>
            $n |-> N:Int
            $s |-> S:Int
        </mem>
    </generatedTop>
    #And
        {
            true
        #Equals
            N:Int >=Int 0
        }

    Kore (1)> stepf 100
    Proof completed on all branches.
    ```


19. To see the proof tree/graph, run `graph` or `graph src/while-loop-proof png` where `src/while-loop-proof` is the filename 
of the saved image and `png` is its format.
    ```shell
    Kore (1)> graph src/proof_tree png
    ```
    ![proof_tree.png](./proof_tree.png)


20. To go to any of the proof step/node, say `N`, run `select N`. For example, if we want to take a look 
at node 7 and beyond, run the following code in sequence:
    ```shell
    select 7
    konfig
    step
    select 8
    konfig
    select 9
    konfig
    ```
    Do you understand why the proof tree branches at node 7? 


21. To find out the details of an axiom used in the proof tree, run `kaxiom N` where 
`N` represents the axiom number shown in the proof tree. E.g.,:
    ```shell
    Kore (9)> kaxiom 1
    ( #Top
    #And
    <generatedTop>
        <k>
            if ( true ) eVarTHEN:Stmt else eVar_ELSE:Stmt ~> eVar_DotVar1:K
        </k>
        eVar_Gen0:StoreCell
    </generatedTop> ) => <generatedTop>
    <k>
        eVarTHEN:Stmt ~> eVar_DotVar1:K
    </k>
    eVar_Gen0:StoreCell
    </generatedTop>

    /home/jinxinglim/Codes/RV/k-tutorial-atva-2023/K_hands_on/src/control-flow.k:110:9-110:57
    ```
    The last line shows where the axiom is located in your file system.