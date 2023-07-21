// Calculator syntax
module ASSIGNMENT-SYNTAX
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
    > left:                     // left: indicates left associativity 
        IExp "^" IExp           // and > indicates lower priority of below productions
    > left:                   
        IExp "*" IExp  
      | IExp "/" IExp 
    > left:
        IExp "+" IExp   
      | IExp "-" IExp 

    // A Boolean expression is either a Boolean value
    syntax BExp ::= Bool
    // Integer comparison syntax
    syntax BExp ::= 
        "(" BExp ")" [bracket]
    | IExp "<=" IExp 
    | IExp "<"  IExp 
    | IExp ">=" IExp 
    | IExp ">"  IExp 
    | IExp "==" IExp 
    | IExp "!=" IExp 

    // Propositional connective syntax
    syntax BExp ::= 
        BExp "&&" BExp 
      | BExp "||" BExp 

   // A statement is
   syntax Stmt ::=  
        // either an assignment
        Id "=" IExp ";"
        // or an expression (without ;)
      | Exp 
        // or a (left-associative) sequence of statements 
      | Stmt Stmt [left]

endmodule    

// Calculator semantics
module ASSIGNMENT
    imports INT
    imports BOOL
    imports MAP
    imports ASSIGNMENT-SYNTAX 

   configuration
      // K cell, containing the statement to be evaluated
      <k> $PGM:Stmt </k>
      // Memory store, modelled as a K map
      <mem> 
         .Map // initially an empty map
      </mem>    

    // Syntax of `substI` Integer expression substitution 
    syntax Int ::= substI ( IExp , Map ) [function]

    // Integer expression evaluation via explicit substitution 
    rule 
      <k> IE:IExp => substI(IE, STORE) </k>
      <mem> STORE </mem>
      requires notBool isInt(IE) // so that it will not go into a loop

    // Base case: integer values evaluate to themselves
    rule substI(I:Int, _STORE) => I

    // Base case: identifiers evaluate to their value in the store
    rule substI(I:Id, STORE) => {STORE [ I ]}:>Int

    // Inductive cases 
    rule substI(I1 + I2, STORE) => substI(I1, STORE) +Int substI(I2, STORE)
    rule substI(I1 - I2, STORE) => substI(I1, STORE) -Int substI(I2, STORE)
    rule substI(I1 * I2, STORE) => substI(I1, STORE) *Int substI(I2, STORE)
    rule substI(I1 / I2, STORE) => substI(I1, STORE) /Int substI(I2, STORE)
    rule substI(I1 ^ I2, STORE) => substI(I1, STORE) ^Int substI(I2, STORE)

    // Boolean expression substitution
    syntax Bool ::= substB ( BExp , Map ) [function]

    // Boolean expression evaluation via explicit substitution 
    rule 
        <k> BE:BExp => substB(BE, STORE) </k>
        <mem> STORE </mem>
        requires notBool isBool(BE) // so that it will not go into a loop

    // Base case: Boolean values evaluate to themselves
    rule substB(B:Bool , _STORE) => B

    // Inductive cases 
    rule substB(I1 <= I2, STORE) => substI(I1, STORE)  <=Int substI(I2, STORE)
    rule substB(I1  < I2, STORE) => substI(I1, STORE)   <Int substI(I2, STORE)
    rule substB(I1 >= I2, STORE) => substI(I1, STORE)  >=Int substI(I2, STORE)
    rule substB(I1  > I2, STORE) => substI(I1, STORE)   >Int substI(I2, STORE)
    rule substB(I1 == I2, STORE) => substI(I1, STORE)  ==Int substI(I2, STORE)
    rule substB(I1 != I2, STORE) => substI(I1, STORE) =/=Int substI(I2, STORE)
    rule substB(B1 && B2, STORE) => substB(B1, STORE) andBool substB(B2, STORE)
    rule substB(B1 || B2, STORE) => substB(B1, STORE)  orBool substB(B2, STORE)

    // Assignment
    rule 
        <k> ID = IE ; => . ... </k>
        <mem> STORE => STORE [ ID <- substI(IE, STORE) ] </mem>

    // Sequencing
    rule 
        <k> S1:Stmt S2:Stmt => S1 ~> S2 ... </k>

endmodule