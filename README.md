# BigNum Workshop

This is a hands-on workshop that teaches how to build a BigNum (large integer arithmetic) library in Noir through progressive stages. The repository contains multiple branches, each representing a stage in the development process.

## Workshop Stages

This workshop is split into branches:
- `stage0`: Basic BigNum implementation
- `stage1`: Generic BigNum with type parameters
- `stage2a`: BigNum trait interface
- `stage2b`: Operator overloading (+, *, ==)
- `stage3`: Metaprogramming with derive_bignum

## Noir version compatibility

This library is tested to work as of Noir version 0.36.0 & 1.0.0-beta.x.

## Benchmarks

Benchmarks are ignored by `git` and checked on pull-request. As such, benchmarks may be generated
with the following command.

```bash
# execute the following
./scripts/build-brillig-report.sh
./scripts/build-gates-report.sh
```

We use standard github action for benchmarks. For a new repository, we need to create a branch gh-pages first.

## Installation

In your _Nargo.toml_ file, add the version of this library you would like to install under dependency:

```toml
[dependencies]
LIBRARY = { tag = "v0.1.0", git = "https://github.com/noir-lang/LIBRARY_NAME" }
```

## `library`

### Usage

`PLACEHOLDER`

