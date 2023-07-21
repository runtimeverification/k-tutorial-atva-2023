## P2. Calculator with Boolean Expressions

In this exercise, we extend the calculator of Exercise 1 to include Boolean expressions, 
such as the standard propositional connectives and integer comparisons. 
The syntax extension is straightforward, introducing the Bool built-in sort for Booleans, 
and defining top-level expressions as either integers or Booleans.

1. Create another copy of `calc.k` and rename it as `calc-bool.k` in `src/`.
    ```shell
    cp src/calc.k src/calc-bool.k
    ```

2. Rename the `CALC-SYNTAX` module name to `CALC-BOOL-SYNTAX` and add the necessary Bool expressions in this module:
    ```k
    // Expression calculator syntax
    module CALC-BOOL-SYNTAX
        imports INT-SYNTAX  // Int is the K built-in integer sort
        imports BOOL-SYNTAX // Bool is the K built-in Boolean sort

        // Expressions are either integers or Booleans
        syntax Exp ::= Int | Bool

        // Integer arithmetic syntax from Exercise 1
        syntax Int ::= 
            ...

        // Integer comparison syntax
        syntax Bool ::= 
            "(" Bool ")" [bracket]
        | Int "<=" Int [function]
        | Int "<"  Int [function]
        | Int ">=" Int [function]
        | Int ">"  Int [function]
        | Int "==" Int [function]
        | Int "!=" Int [function]

        // Propositional connective syntax
        syntax Bool ::= 
            Bool "&&" Bool [function]
          | Bool "||" Bool [function]
    endmodule
    ```

    **Key points**
    - `syntax Exp ::= Int | Bool`: To indicate that expressions used to define the semantics will be either `Int` or `Bool`.
    - `BOOL-SYNTAX`: K built-in module to use boolean sort `Bool`.

3. Rename the `CALC` module name to `CALC-BOOL` and add the necessary Bool rules in this module:
    ```k
    // Expression calculator semantics
    module CALC-BOOL
        imports INT
        imports BOOL
        imports CALC-BOOL-SYNTAX

        configuration
            // K cell, containing the expression to be evaluated
            <k> $PGM:Exp </k>

        // Integer arithmetic semantics from Exercise 1
        ...

        // Integer comparison semantics
        rule I1 <= I2 => I1  <=Int I2
        rule I1  < I2 => I1   <Int I2
        rule I1 >= I2 => I1  >=Int I2
        rule I1  > I2 => I1   >Int I2
        rule I1 == I2 => I1  ==Int I2
        rule I1 != I2 => I1 =/=Int I2

        // Propositional connective semantics
        rule B1 && B2 => B1 andBool B2
        rule B1 || B2 => B1  orBool B2
    endmodule
    ```

    **Key points**
    - `BOOL`: K built-in module to use boolean connectives `andBool` and `orBool`.
    - `configuration`: To define cell configuration K should recognize. 
    In this case, `<k> $PGM:Exp </k>` defines the (default) K cell to recognize `Exp` as `$PGM` (program)


4. Remove the compiled `calc-kompiled` directory (remember to do this before compiling new module) 
and compile our new `calc-bool.k`:
    ```shell
    rm -rf calc-kompiled/
    kompile src/calc-bool.k
    ```

5. Run the tests provided in `tests/`:
    ```shell
    krun tests/2.calc-bool-test1
    krun tests/2.calc-bool-test2
    krun tests/2.calc-bool-test3
    ```