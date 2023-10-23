# Kontrol Hands-on

This directory contains instructions and smart contracts for the Kontrol tutorial.

For this part of the tutorial, we will be using `K_Hands_on/` as our working directory:
```shell
cd Kontrol_hands_on/
```

## Installation of Kontrol

The easiest way to install Kontrol is via `kup`:
```shell
bash <(curl https://kframework.org/install)
kup install kontrol
```
You can update Kontrol with:

```shell
kup update kontrol
```

And list available versions with:

```shell
kup list
```

This will take care of all the dependencies and specific versions used by Kontrol. The tutorial will be done using VS Code but please feel to use any editor you prefer. For VS Code users, you can install the ["K Framework" extension](https://marketplace.visualstudio.com/items?itemName=RuntimeVerification.k-vscode) to help you with editing the code.

To install Foundry separately, run
```sh
curl -L https://foundry.paradigm.xyz | bash
```
followed by 
```sh
foundryup
```

You can check the installed version of Foundry via
```sh
forge --version
```

## Hands-on Exercises

### K1. Fuzzing `Counter`

To create a Foundry project, create a new directory
```sh
mkdir foundry-project && cd foundry-project
```
and initialize a new Foundry project with the appropriate structure by running
```sh
forge init --no-commit
```
To fuzz the existing tests, e.g., `testFuzz_SetNumber(uint256 x)` run
```sh
forge test
```

Let's check if Foundry can correcty detect a failing test. Add the following simple test to `Counter.t.sol`:
```solidity
   function test_failure(uint256 x) public {
        if (x == 4) {
            assert(false);
        }
   }
```
`forge test` should correctly report the failure and produce a counterexample (`x = 4`). Let's make the counterexample more challenging to identify by making a constant bigger (e.g., `4` -> `421`). Most of the time, Foundry cannot identify the failure within default 256 runs. The number of runs can be increased by adding the corresponding property to the `foundry.toml` file:
```
[fuzz]
runs = 65536
```
Other configuration options are available in Foundry docs: https://github.com/foundry-rs/foundry/blob/master/crates/config/README.md#all-options.

### K2. Verifying `Counter`


Now, let's make the test even more complex. Let's rewrite the `Counter` contract, adding an additional parameter `bool inLuck` to the `setNumber` function as well as a custom `error`:
```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;
    bool public isActive;

    error CoffeeBreak();

    function setNumber(uint256 newNumber, bool inLuck) public {
        number = newNumber;
        if (newNumber == 0xC0FFEE && inLuck == true) {
            revert CoffeeBreak();
        }
    }

    function increment() public {
        number++;
    }
}
```
Let's also modify the `testFuzz_SetNumber` to reflect this change:
```solidity
   function testFuzz_SetNumber(uint256 x, bool inLuck) public {
       counter.setNumber(x, inLuck);
       assertEq(counter.number(), x);
   }
```
Now, the test should fail if `x` equals `0xC0FFEE` and `inLuck` is `true`. Run `forge test` to run another fuzzing campaign. Most of the time, Foundry does not report this test as failing even with the increased number of runs.

Symbolic testing performed by `kontrol`, however, is well-suited for identifying this violation. To kompile the project, run
```
kontrol build
```
Now, to verify this test, you can run 
```sh
kontrol prove --test CounterTest.testSetNumber \
              --use-booster \
              --counterexample-information
```
`kontrol` should report the failure and report the corresponding counterexample.

You can also examine the corresponding KCFG (K Control-Flow Graph) in the interactive viewer via
```
kontrol view-kcfg –-test CounterTest.testSetNumber
```
The list of proofs and their statuses is available through
```
kontrol list
```

### K3. Verifying `Counter` with Cheatcodes

To make analysis and verification of `Counter` even more challenging, let's add another variable `isActive` to the `Counter` contract and add this variable to the condition checked in `setNumber`:
```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;
    bool public isActive;

    error CoffeeBreak();

    function activate() public {
        isActive = true;
    }

    function setNumber(uint256 newNumber, bool inLuck) public {
        number = newNumber;
        if (newNumber == 0xC0FFEE && inLuck == true && isActive == true) {
            revert CoffeeBreak();
        }
    }

    function increment() public {
        number++;
    }
}
```
`isActive` is a state variable, which, in Solidity, is `false` by default. To make it `true`, one should called `activate()` function. In Foundry, that function should have been added to the test or a `setUp` function explicitly.

Kontrol provides a solution that reduces the number of function calls and allows for more exhaustive verification by letting the user assume that the storage is _symbolic_. This is available through Kontrol-specific cheatcodes, which can be installed as follows:
```sh
forge install runtimeverification/kontrol-cheatcodes --no-commit
``` 

Once the `KontrolCheats` cheatcode library is installed, it can be used as follows:
```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Counter.sol";
import "kontrol-cheatcodes/KontrolCheats.sol";

contract CounterTest is Test, KontrolCheats {
   Counter public counter;

   function setUp() public {
       counter = new Counter();
       counter.setNumber(0, false);
   }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

   function testFuzz_SetNumber(uint256 x, bool inLuck) public {
       // counter.activate();
       kevm.symbolicStorage(address(counter));
       counter.setNumber(x, inLuck);
       assertEq(counter.number(), x);
   }
}
``` 
Here, `kevm.symbolicStorage(address(counter));` indicates that the storage variables in the contract deployed at address `counter` are symbolic — therefore, we will be considering the case of `inActive` being `true`.

Re-run `kontrol build --rekompile && kontrol prove --reinit --use-booster --test CounterTest.testFuzz_SetNumber` to check.

