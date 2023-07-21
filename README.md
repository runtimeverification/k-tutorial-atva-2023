# The K Framework: A tool kit for language semantics and verification


This is the main repository we will be using for the tutorial sessions during the [21st International Symposium on Automated Technology for Verification and Analysis (ATVA 2023)](https://atva-conference.org/2023/). The tutorial sessions will be held on _date_ from _start_time_ to _end_time_. 

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

## Contents

### AM Session - Introduction to K slides
### [K Hands-on working directory](https://github.com/runtimeverification/k-tutorial-atva-2023/tree/master/K_hands_on)
### PM Session - KEVM: Formal Semantics of Ethereum VM slides
### KEVM Hands-on working directory

## Other K materials

1. [K Github repository](https://github.com/runtimeverification/k)

2. [Do the K tutorial!](https://kframework.org/k-distribution/k-tutorial/)

3. [Build programming languages in K!](https://kframework.org/k-distribution/pl-tutorial/)

4. [K User Manual](https://kframework.org/docs/user_manual/)

5. [K research problems](https://research.runtimeverification.com/)
