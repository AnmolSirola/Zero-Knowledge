## Why Circom Exists
Circom was created to address two major issues in developing constraint systems for SNARKs.

1) Manually designing constraint systems is tedious and error-prone, especially when dealing with large-scale or repetitive constraints.
2) Populating the witness is equally challenging and requires manual computation of intermediary values that could otherwise be derived programmatically.

Thus, Circom:

  1) Simplifies constraint design  
  2) Automates witness population.

### Working:
Circom further simplifies the witness population through its “assign and constrain” operator `<==`

Suppose we have the constraint:
        `z === x * y`

If we supply the values for x and y, it would be a bit annoying to also have to supply the value for z because z only has one possible solution.

With Circom, we use <== as follows:
`z <== x * y`

With this, the variable z no longer needs to be provided as an input as Circom populates it for us, and its value will be locked into 
for the rest of the circuit.

Hence, Circom saves a user from the hassle of explicitly providing a value for every element in the witness, which is a major selling point for Circom’s convenience.

#### template , component , main

- Templates define a blueprint for circuits, like a class defines the structure for objects in OOP (Object Oriented Programming).
- A component is an instantiation of a template, similar to how an object is an instance of a class in Object Oriented Programming.

```ts
// create template
template SomeCircuit() {
  // .... stuff
}

// instantiate template 
component main = SomeCircuit();
```

`component main = SomeCircuit()` is needed because Circom requires a single top-level component, main, to define the circuit structure that will be compiled.

#### Signal input

- Signal inputs are values that will be provided from outside the component. (Circom does not enforce a value is actually provided — it is up to the developer to ensure that the values are actually supplied. If they aren’t, this can lead to a security vulnerability.)
- Input signals are immutable and cannot be altered.
- Signals are exactly the variables in a Rank 1 Constraint System witness vector.

#### The Finite Field of Circom
Circom performs arithmetic in a `finite field` with an order of `21888242871839275222246405745257275088548364400416034343698204186575808495617`, which we will simply call 
. It is a `254-bit number`, corresponding to the curve order of the bn128 elliptic curve. This curve is widely used, in particular it’s the one made available via precompiles in the EVM. Since Circom was intended to be used for developing ZK-SNARK applications on Ethereum, it makes sense to make the field size match the curve order of the bn128 curve.

Circom allows the default order to be changed via command-line argument.

The following should be obvious to the reader:

- `p` under `mod p` is congruent to `0`;
- `p-1` is the largest integer in the `finite field` `mod p`.
- Passing values that are larger than `p-1` will result in overflow.

### Circom in the command line

### 1. Compiling Circuits

Execute the following command to compile: `circom somecircuit.circom --r1cs --sym --wasm`

- The `--r1cs` flag means to output an r1cs file. 
  - This file contains the circuit’s R1CS system of constraints in binary format.
  - Can be used with different tool stacks to construct proving/verifying statements (e.g. snarkjs, libsnark).
  - Running `snarkjs r1cs print somecircuit.r1cs`, we'll get a human-readable output:

- The `--sym flag` gives the variables a human-readable name. This file is a symbols file generated during compilation. This file is essential because:
  - It maps human-readable variable names to their corresponding positions in the R1CS for debugging.
  - It helps in printing the constraint system in a more understandable format, making it easier to verify and debug your circuit.

- The `-wasm` is for generating wasm code to populate the witness of the R1CS, given an input JSON.

### 2. Calculating the Witness

- To generate the witness, we must supply the public input values for the circuit. We do this by creating an `inputs.json` file in the `somecircuit_js` directory.

- Say we want to create a witness for input values `a=1`, `b=2`, `c=2`. The JSON file would be like so:

- `{"a": "1","b": "2","c": "2"}`

- Circom expects strings instead of numbers because JavaScript does not work accurately with integers larger than (source).

- Run this command in the somecircuit_js directory: `node generate_witness.js **somecircuit.wasm** inputs.json witness.wtns` (in the `somecircuit_js directory`)

- Now that `witness.wtns` has been created, export it to JSON, so we can examine it: `snarkjs wtns export json witness.wtns`

- We would get an output on executing the witness.json.

