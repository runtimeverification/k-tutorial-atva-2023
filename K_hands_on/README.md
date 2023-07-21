# K Hands-on

This directory consists of tutorial materials that will provide users a quick start to [K framework](https://kframework.org/). 
We will follow the [From 0 to K tutorial](https://runtimeverification.com/blog/from-0-to-k-tutorial) closely where 
we will build a simple calculator program language and formal verify some properties using K.

For this part of the tutorial, we will be using `K_Hands_on/` as our working directory:
```shell
cd K_Hands_on/
```

## Installation of K

We only support installing of K on Linux and macOS. 
For Windows users, please create a virtual machine with a Linux distribution (e.g. Ubuntu Focal Fossa) installed on it. 
Otherwise, you can install the Windows Subsystem for Linux (version 2) and follow the instructions for installing Ubuntu Focal. 
For more information on the kup tool and other packaged releases of K, please refer to our [installation notes](https://github.com/runtimeverification/k/blob/master/k-distribution/INSTALL.md).

If you're on a system that supports [Nix](https://nixos.org/download.html), use this command to install via Nix:

```shell
bash <(curl https://kframework.org/install)
kup install k
```

You can update K with:

```shell
kup update k
```

And list available versions with:

```shell
kup list
```

This will take care of all the dependencies and specific versions used by K. Note that the first run will take longer (30m to 1h) to fetch all the libraries and compile sources. If you are on Apple Silicon, `kup` is currently the only way to install K because of upstream issues in the general Haskell ecosystem.

The tutorial will be done using VS Code but please feel to use any editor you prefer. 
For VS Code users, you can install the "K Framework" extension to help you with editing the code.

**Note:** Each of the following contents are written in the respective directory's README.md with the working directory set as
`K_Hands_on/`.

## Contents

### P1. Calculator
### P2. Calculator with Boolean Expressions
### P3. Variables in Expressions, Explicit Substitution
### P4. Assignment Operator
### P5. Control Flow
### P6. Procedures (Optional)
