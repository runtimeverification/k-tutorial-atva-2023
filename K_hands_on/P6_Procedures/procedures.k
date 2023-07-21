// Calculator syntax
module PROCEDURES-SYNTAX
    imports INT-SYNTAX  // Int is the K built-in integer sort
    imports BOOL-SYNTAX // Bool is the K built-in Boolean sort
    imports ID          // Id is the K built-in sort for identifiers (variables)imports ID-SYNTAX

    // Signal when expression evaluation should stop
    syntax KResult ::= Int | Bool | Ints

    // Expressions are either integers or Booleans
    syntax Exp ::= IExp | BExp

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
    | Id "(" Exps ")" [strict(2)]

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
      | "return" IExp ";"                    [seqstrict] // Return statement
      | "def" Id "(" Ids ")" Block                       // Function definition

    syntax Block ::=
        "{" Stmt "}"                                   // Block statement
      | "{"      "}"                                   // Empty block
    
endmodule    

// Calculator semantics
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

endmodule