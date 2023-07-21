// Calculator syntax
module CONTROL-FLOW-SYNTAX
    imports INT-SYNTAX  // Int is the K built-in integer sort
    imports BOOL-SYNTAX // Bool is the K built-in Boolean sort
    imports ID          // Id is the K built-in sort for identifiers (variables)imports ID-SYNTAX

   // Signal when expression evaluation should stop
   syntax KResult ::= Int | Bool

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

// Calculator semantics
module CONTROL-FLOW
    imports INT
    imports BOOL
    imports MAP
    imports CONTROL-FLOW-SYNTAX 

   configuration
      // K cell, containing the statement to be evaluated
      <k> $PGM:Stmt </k>
      // Memory store, modelled as a K map
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

   // Block statements
   rule <k> { S } => S ... </k>
   rule <k> {   } => . ... </k>

   // If conditional
   rule <k> if (true)   THEN else _ELSE => THEN ... </k>
   rule <k> if (false) _THEN else  ELSE => ELSE ... </k>

   // While loop
   rule <k> while ( BE ) BODY => if ( BE ) { BODY while ( BE ) BODY } else { } ... </k>

endmodule