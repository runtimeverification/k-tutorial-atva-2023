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