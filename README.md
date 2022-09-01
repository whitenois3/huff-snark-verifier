<img align="right" width="150" height="150" top="100" src="./assets/no_step_on_snark.png">

# huff-snark-verifier • [![ci](https://github.com/whitenois3/huff-snark-verifier/actions/workflows/ci.yaml/badge.svg)](https://github.com/whitenois3/huff-snark-verifier/actions/workflows/ci.yaml)

> `huff-snark-verifier` offers an optimized Groth16 SNARK verification smart contract generator for EVM-based blockchains.

> **Warning**
> This software is experimental, and it has not been audited. Please proceed with caution, and report any bugs in the [Issues](https://github.com/whitenois3/huff-snark-verifier/issues).

## Gas Report

| VERSION             | GAS CONSUMED |
| ------------------- | ------------ |
| Solidity (1 input)  | 207009       |
| Huff (1 input)      | 188769       |
| Solidity (2 inputs) | 215009       |
| Huff (2 inputs)     | 195368       |

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

You can test your changes to the template contract by regenerating the single-input & multi-input sample verifiers and running `forge test`. See the [Testing](#Testing) section above.

### To Do

- [x] Tests for proofs with multiple inputs & fail cases.
  - [ ] More tests for circuits with more public inputs.
- [x] Finish `huffv`.
  - [ ] Possibly clean up with the [handlebars crate](https://crates.io/crates/handlebars) instead of `.replace`?
- [ ] External verification function template.
- [x] Add documentation / README.
- [ ] Clean and update comments. (Double check stack comments!)
- [ ] More runtime gas / code size optimizations.

## License

Released under the [GNU GPLv3 License](./LICENSE.md). Go wild.
