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
}

contract VerifierTest is Test {
    Verifier public solVerifier;
    IHuffVerifier public huffVerifier;

    function setUp() public {
        string memory wrapper_code = vm.readFile("test/wrappers/VerifierWrapper.huff");
        huffVerifier = IHuffVerifier(HuffDeployer.deploy_with_code("contracts/Verifier", wrapper_code));
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
}
