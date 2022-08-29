// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import {Pairing, Verifier} from "../src/contracts/Verifier.sol";
import "foundry-huff/HuffDeployer.sol";

interface IHuffVerifier {
    function negate(Pairing.G1Point memory a) external pure returns (Pairing.G1Point memory r);
    function addition(Pairing.G1Point memory a, Pairing.G1Point memory b) external view returns (Pairing.G1Point memory r);
    function scalar_mul(Pairing.G1Point memory p, uint s) external view returns (Pairing.G1Point memory r);
    function pairing(Pairing.G1Point[] memory p1, Pairing.G2Point[] memory p2) external view returns (bool);
    function verify(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[] memory input) external view returns (bool);
}

contract VerifierTest is Test {
    Verifier public verifier;
    IHuffVerifier public huffVerifier;

    function setUp() public {
        string memory wrapper_code = vm.readFile("test/wrappers/VerifierWrapper.huff");
        huffVerifier = IHuffVerifier(HuffDeployer.deploy_with_code("contracts/Verifier", wrapper_code));
        verifier = new Verifier();
    }

    function testNegate() public {
        Pairing.G1Point memory point = Pairing.G1Point(1, 2);
        Pairing.G1Point memory solRes = Pairing.negate(point);
        Pairing.G1Point memory huffRes = huffVerifier.negate(point);

        assertEq(abi.encode(solRes), hex"000000000000000000000000000000000000000000000000000000000000000130644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd45");
        assertEq(abi.encode(solRes), abi.encode(huffRes));
    }

    function testAdd() public {
        Pairing.G1Point memory a = Pairing.G1Point(1, 2);
        Pairing.G1Point memory b = Pairing.G1Point(1, 2);
        Pairing.G1Point memory solRes = Pairing.addition(a, b);       
        Pairing.G1Point memory huffRes = huffVerifier.addition(a, b);       

        assertEq(abi.encode(solRes), hex"030644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd315ed738c0e0a7c92e7845f96b2ae9c0a68a6a449e3538fc7ff3ebf7a5a18a2c4");
        assertEq(abi.encode(solRes), abi.encode(huffRes));
    }

    function testScalarMul() public {
        Pairing.G1Point memory a = Pairing.G1Point(1, 2);
        uint s = 2;
        Pairing.G1Point memory solRes = Pairing.scalar_mul(a, s);       
        Pairing.G1Point memory huffRes = huffVerifier.scalar_mul(a, s);       

        assertEq(abi.encode(solRes), hex"030644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd315ed738c0e0a7c92e7845f96b2ae9c0a68a6a449e3538fc7ff3ebf7a5a18a2c4");
        assertEq(abi.encode(solRes), abi.encode(huffRes));
    }

    function testPairing() public {
        Pairing.G1Point[] memory g1_points = new Pairing.G1Point[](2);
        g1_points[0] = Pairing.P1();
        g1_points[1] = Pairing.negate(Pairing.P1());

        Pairing.G2Point[] memory g2_points = new Pairing.G2Point[](2);
        g2_points[0] = Pairing.P2();
        g2_points[1] = Pairing.P2();

        bool solRes = Pairing.pairing(g1_points, g2_points);

        assertEq(solRes, true);
    }

    function testVerifyProof() public {
        uint[2] memory a = [
            0x0fa55097071458e4e105175cafdd75c0b4c6f639227db56ab908050dc99c6220,
            0x0ac50ef419a1e1f29f5ff0d1898af514a36bc42ba970fd503060a6123c6d8f6c
        ];

        uint[2][2] memory b = [
            [
                0x23cfed79e17316667872d9377d23c9553321bf162b566facf05f262fe1a534ca,
                0x0a658672d02e119820017f116b913ec347182ba17b24416b683bee1d07a200db
            ],
            [
                0x2c9661cac208dc71f2b5f48f4ed82b224056fb2fba1ff9792ec96bf3ea9a6f92,
                0x1c8e9ccb3fffcda4e6df7f2fa8f8f767c3fb868493d36788df6977f1001802f7
            ]
        ];

        uint[2] memory c = [
            0x2038751350aad5781c0e5c1f245d75d6ea198ca6bc42440ae1fc74ee99841921,
            0x06ab85db3cf7d039bb4da84c2d6137ff93c3490a79146548949d1531a3455353
        ];

        uint[] memory inputs = new uint[](1);
        inputs[0] = uint(182377969136052884622247920755931704678273168534);
        
        assertEq(huffVerifier.verify(a, b, c, inputs), true);
        assertEq(verifier.verifyProof(a, b, c, inputs), true);
    }
}
