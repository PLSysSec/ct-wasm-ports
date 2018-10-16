# CT-WASM Evalution Suite

This directory contains the artifacts and scripts required to build and evaluate CT-WASM and its associated tools.

## Prequisites

The eval suite depends on the following tools and libraries.

- git
- node
- python3 + numpy
- GNU coreutils


### Transitive Dependencies

(Copied from their respective projects)

**Node.js w/ CT-WASM**

 - gcc and g++ 4.9.4 or newer, or
 - clang and clang++ 3.4.2 or newer (macOS: latest Xcode Command Line Tools)
 - Python 2.6 or 2.7
 - GNU Make 3.81 or newer

**Reference Interpreter**

- Ocaml >= 4.05
- ocamlbuild
- Ocaml num library (for extracted verified compiler). OPAM users can install the num library with: `opam install num`.

## Building

In this directory, simply run:

```bash
$ make
```

This script will take care of downloading and building all the appropriate tools. You can, howerver, build all the tools with `make tools`.


## Usage
A simple `make eval` command will build most of the eval and all of the tools.
Dudect and tweetnacl benchmarks are too slow to run by default so they must be run manually.

TweetNacl is benchmarked using:

```bash
$ make tweetnacl
```

This only runs the suite once. If you want to run it multiple times, edit `TWEET_TRIALS` in the Makefile.

Dudect runs for a specified amount of time on all samples. It is invoked like so:
`DUDE_TIMOUT=60 make dudect`

Many of the test suites have configurable trial counts in the Makefile.
