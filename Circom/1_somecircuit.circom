pragma circom 2.1.8;

template SomeCircuit() {
  // inputs
  signal input a;
  signal input b;
  signal input c;

  // constraints 
  c  === a * b;
}

component main = SomeCircuit();