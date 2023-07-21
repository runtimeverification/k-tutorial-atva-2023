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

    rule maxInt(X, Y) => Y requires         X <Int Y [simplification]
    rule maxInt(X, Y) => X requires notBool X <Int Y [simplification]

    rule { MAP [ K <- V' ] #Equals MAP [ K <- V ] } => { V' #Equals V } [simplification]
endmodule

// Module for all claims to be proven
module CONTROL-FLOW-SPEC
    imports VERIFICATION

    claim <k> 3 + 4 => 7 </k>

    claim <k> if ( 3 < 4 ) {
                $c = 1 ;
              } else {
                $c = 2 ;
              }
           => . ... </k>
          <mem> STORE => STORE [ $c <- 1 ] </mem>

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

    claim <k> $a = A:Int ; $b = B:Int ;
              if (A < B) {
                $c = B ;
              } else {
                $c = A ;
              }
           => . ... </k>
          <mem> STORE => STORE [ $a <- A ] [ $b <- B ] [ $c <- maxInt(A, B) ] </mem>

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

endmodule