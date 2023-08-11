# The K Framework: A tool kit for language semantics and verification


This is the main repository we will be using for the tutorial sessions during the [21st International Symposium on Automated Technology for Verification and Analysis (ATVA 2023)](https://atva-conference.org/2023/).

**Date:** 24 October 2023    
**Time:** AM session - _start_time_ to _end_time_, PM session - _start_time_ to _end_time_    
**Venue:** _venue_

## Announcements

1. Clone this repository for the tutorial materials:
    ```shell
    git clone https://github.com/runtimeverification/k-tutorial-atva-2023.git
    ```

2. To join our hands-on sessions, **please install K prior to attending the them** as it may take some time ranging from 15 minutes to an hour to get it fully installed. Furthermore, we only support installing of K on Linux and macOS. For Windows users, please create a virtual machine with a Linux distribution (e.g. Ubuntu Focal Fossa) installed on it. Otherwise, you can install the Windows Subsystem for Linux (version 2) and follow the instructions for installing Ubuntu Focal. For more information on the kup tool and other packaged releases of K, please refer to our [installation notes](https://github.com/runtimeverification/k/blob/master/k-distribution/INSTALL.md).

### Installation of K

To install K, we provide a streamlined installation process for any system that supports [Nix](https://nixos.org/download.html):

```shell
bash <(curl https://kframework.org/install)
kup install k
```

This will take care of all the dependencies and specific versions used by K. Note that the first run will take longer (30m to 1h) to fetch all the libraries and compile sources.

## Abstract

The [K Framework](https://kframework.org/) provides a set of tools for developing programming languages and formal analysis tools. By writing a single description of your language’s syntax and operational semantics, you can use K to automatically extract a parser, interpreter, symbolic execution engine, and many more tools for your language. This approach scales well: K implementations have been built for many mainstream programming languages (C, Rust, Java, Python, EVM, to name a few), and K is used in practice every day for real verification problems.

This tutorial is aimed at anyone who is interested in programming language implementation or program verification, and will be broken down into two main sessions (AM and PM session):

### AM session
We will build a simple imperative language in K, where we will define syntax and operational semantics of the language we are building. With the language definition in hand, we will take advantage of K’s support for deductive verification to write some simple proofs over programs. By the end of this session, the attendees should be able to implement and verify their next research DSL or language of interest using K.

### PM session
We will verify the properties of Ethereum smart contracts using KEVM, a complete formal semantics of Ethereum Virtual Machine (EVM). To provide the attendees with the necessary background knowledge, we will go through the basics of blockchain, EVM, Solidity—the most popular smart contract language, and Foundry—a reliable and easy-to-setup tool that is widely used by smart contract developers and auditors, before moving onto KEVM. By the end of this session, the attendees will be able to prove properties of Ethereum smart contracts by defining them through test functions in Foundry and verifying them using KEVM.

## Contents

### AM Session - Introduction to K (slides)
### [K Hands-on](K_hands_on/)
### PM Session - KEVM: Formal Semantics of Ethereum VM (slides)
### KEVM Hands-on

## Other K materials

1. [K Github repository](https://github.com/runtimeverification/k)

2. [Do the K tutorial!](https://kframework.org/k-distribution/k-tutorial/)

3. [Build programming languages in K!](https://kframework.org/k-distribution/pl-tutorial/)

4. [K User Manual](https://kframework.org/docs/user_manual/)

5. [K research problems](https://research.runtimeverification.com/)
