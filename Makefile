tests:
	cargo run --bin huffv ./test/multi-input/sample_verification_key.json > ./test/multi-input/SampleVerifier.huff
	cargo run --bin huffv ./test/single-input/sample_verification_key.json > ./test/single-input/SampleVerifier.huff