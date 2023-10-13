## P1. Calculator

Our first example is that of a calculator that works with simple integer arithmetic, that is, 
addition, subtraction, multiplication, division, and exponentiation, and the first step is to 
define the appropriate syntax and semantics.

1. Create a new directory `src/` with a new K file named `calc.k` in it:
    ```shell
    mkdir src
    touch src/calc.k
    ```

2. Open the file `calc.k` with your prefered editor and add the following code in it:
    ```k
    // Calculator syntax
    module CALC-SYNTAX
        imports INT-SYNTAX  // Int is the K built-in integer sort

        // Integer arithmetic syntax
        syntax Int ::= Int "+" Int [function] 
                     | Int "-" Int [function]
                     | Int "*" Int [function] 
                     | Int "/" Int [function] 
                     | Int "^" Int [function]
    endmodule

    // Calculator semantics
    module CALC
        imports INT
        imports CALC-SYNTAX 

        // Integer arithmetic semantics
        rule I1 + I2 => I1 +Int I2
        rule I1 - I2 => I1 -Int I2
        rule I1 * I2 => I1 *Int I2
        rule I1 / I2 => I1 /Int I2
        rule I1 ^ I2 => I1 ^Int I2
    endmodule
    ```
    
    **Key points:**
    - `module ... endmodule`: To define a module.
    - `imports`: To import module. 
    - `INT-SYNTAX` and `INT`: K built-in modules to use integer sort `Int` and the integer arithmetic semantics such as `+Int`, etc. 
    To find out more about the built-in modules that K provides, please refer to [K Builtins](https://kframework.org/k-distribution/include/kframework/builtin/).
    - `syntax ... ::= ...`: To define syntax.
    - `[function]`: To indicate the syntax defined is a function.
    - `rule ... => ...`: To define rewrite rule which works as the semantic of a defined syntax.
    

3. Compile the program `calc.k` that you have created:
    ```shell
    kompile src/calc.k
    ``` 
    This will generate a directory called `calc-kompiled/` which consists of all the necessary files required to run the program.


4. There are two ways to test out the program that you have just built:    
    a. Run it directly using `krun -cPGM`:
    ```shell
    krun -cPGM='3 + 3'
    ```

    b. Create a new test file with the program you want to test with in the file and run it with `krun` (we have provided you a sample test file `tests/calc-test1`):
    ```shell
    krun tests/1.calc-test1
    ```

    Using either way, you should see that the program has evaluated to 6:
    ```
    <k>
        6 ~> .
    </k>
    ```
    (Ignore the `<k>`, `</k>` and `~> .`.)


5. At the current state, we cannot run program such as `(1 + 2) * 3` or `1 + 2 * 3` due to the fact that brackets, 
ordering and associativity have not been defined for our calculator program. 
Modify the `calc.k` such that the following code is in the file:
    ```k
    // Calculator syntax
    module CALC-SYNTAX
        imports INT-SYNTAX  // Int is the K built-in integer sort

        // Integer arithmetic syntax
        syntax Int ::= 
            "(" Int ")" [bracket]   
        > left:                     // left: indicates left associativity 
            Int "^" Int [function]  // and > indicates lower priority of below productions
        > left:                   
            Int "*" Int [function] 
          | Int "/" Int [function]
        > left:
            Int "+" Int [function]  
          | Int "-" Int [function] 
    endmodule    

    // Calculator semantics
    module CALC
        imports INT
        imports CALC-SYNTAX 

        // Integer arithmetic semantics
        rule I1 + I2 => I1 +Int I2
        rule I1 - I2 => I1 -Int I2
        rule I1 * I2 => I1 *Int I2
        rule I1 / I2 => I1 /Int I2
        rule I1 ^ I2 => I1 ^Int I2 
    endmodule  
    ```

    **Key points:**
    - `[bracket]`: To indicate the syntax defined is a bracket.
    - `|`: To indicate listing with no ordering
    - `>`: To indicate listing with ordering
    - `left:` To indicate left associativity


 6. Remove the compiled `calc-kompiled` directory (remember to do this before compiling new module) 
and recompile our modified `calc.k` before testing it with `tests/calc-test2` that we have provided 
and check if all values are evaluated correctly:
    ```shell
    rm -rf calc-kompiled/
    kompile src/calc.k
    krun tests/1.calc-test2
    ```