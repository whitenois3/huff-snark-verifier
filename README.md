# huff-snark-verifier

> **Warning**
> This software is experimental, and it has not been audited. Please proceed with caution, and report any bugs in the [Issues](https://github.com/whitenois3/huff-snark-verifier/issues).

huff-snark-verifier offers a hyper-optimized Groth16 SNARK verification smart contract for EVM-based blockchains.

## Gas Report

_TODO_

## Usage

To generate a Huff SNARK verification contract, you must first have a verification key created by [snarkjs](https://github.com/iden3/snarkjs).

1. Install `huffv` (Requires the [rust toolchain](https://www.rust-lang.org/tools/install) to be installed.)

```
git clone git@github.com:whitenois3/huff-snark-verifier.git
cd huff-snark-verifier && cargo build
cargo install --path .
```

2. Generate verification contract

```
huffv ./path/to/verification_key.json [-o <output_file_path>]
```

3. Compile verification contract with [huffc](https://github.com/huff-language/huff-rs)

```
huffc ./Verifier.huff -b
```

## Testing

To run tests for this repo, you will need [forge](https://github.com/foundry-rs/foundry),
[huffc](https://github.com/huff-language/huff-rs), and the [rust toolchain](https://www.rust-lang.org/tools/install) installed.

```sh
# Regenerate single-input verification contract from template
cargo run --bin huffv ./test/single-input/sample_verification_key.json -o ./test/single-input/SampleVerifier.huff

# Regenerate multi-input verification contract from template
cargo run --bin huffv ./test/multi-input/sample_verification_key.json -o ./test/multi-input/SampleVerifier.huff

# Test sample Huff verification contracts against the Solidity version
forge test -vvv
```

## Contributing

All contributions are welcome- create a fork and submit a PR! Please adhere to the PR template provided :smile:

## License

Released under the [GNU GPLv3 License](./LICENSE.md). Go wild.
