# bonsai-foundry-template

## Requirements

Install [Rust(up)](https://rustup.rs/) and [Foundry(up)](https://getfoundry.sh/)

## Build

```
forge build
cargo build --tests
```

## Test

### Without proving

```
forge test
```

Note: The above command might take a while to compile the risc0 guest binary.

### With proving

```
PROVE_LOCALLY=1 forge test
```

Note: The above command might take some time for the proof to be computed.

## Usage

### zkVM Guest Binary

```
methods/guest/src/bin/fibonacci.rs
```

### Solidity Contracts

```
src/BonsaiStarter.sol
```
```
src/BonsaiStarterLowLevel.sol
```

### Foundry Tests

```
test/BonsaiStarter.t.sol
```
```
test/BonsaiStarterLowLevel.t.sol
```