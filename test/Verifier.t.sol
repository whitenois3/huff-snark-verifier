// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "foundry-huff/HuffDeployer.sol";
import {Pairing, Verifier as SingleInputVerifier} from "./single-input/Verifier.sol";
import {Verifier as MultiInputVerifier} from "./multi-input/Verifier.sol";

interface IHuffVerifier {
    function negate(Pairing.G1Point memory a) external pure returns (Pairing.G1Point memory r);
    function addition(Pairing.G1Point memory a, Pairing.G1Point memory b) external view returns (Pairing.G1Point memory r);
    function scalar_mul(Pairing.G1Point memory p, uint s) external view returns (Pairing.G1Point memory r);
    function pairing(Pairing.G1Point[] memory p1, Pairing.G2Point[] memory p2) external view returns (bool);
    function verify(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[] memory input) external view returns (bool);
}

contract VerifierTest is Test {
    /// @notice Single Input Verifiers
    SingleInputVerifier public solSingleInputVerifier;
    IHuffVerifier public huffSingleInputVerifier;
    
    /// @notice Multi Input Verifiers
    MultiInputVerifier public solMultiInputVerifier;
    IHuffVerifier public huffMultiInputVerifier;

    function setUp() public {
        // Instantiate Single Input Verifiers
        string memory single_input_wrapper = vm.readFile("test/single-input/SingleInputWrapper.huff");
        huffSingleInputVerifier = IHuffVerifier(HuffDeployer.deploy_with_code("../test/single-input/SampleVerifier", single_input_wrapper));
        solSingleInputVerifier = new SingleInputVerifier();

        // Instantiate Multi Input Verifiers
        string memory multi_input_wrapper = vm.readFile("test/multi-input/MultiInputWrapper.huff");
        huffMultiInputVerifier = IHuffVerifier(HuffDeployer.deploy_with_code("../test/multi-input/SampleVerifier", multi_input_wrapper));
        solMultiInputVerifier = new MultiInputVerifier();
    }

    ////////////////////////////////////////////////////////////////
    //                      GAS COMPARISONS                       //
    ////////////////////////////////////////////////////////////////

    function testGasSingleInput() public {
        (
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[] memory inputs
        ) = getSingleInputProof();

        uint g = gasleft();
        huffSingleInputVerifier.verify(a, b, c, inputs);
        emit log_named_uint("gas", g - gasleft());

        g = gasleft();
        solSingleInputVerifier.verifyProof(a, b, c, inputs);
        emit log_named_uint("gas", g - gasleft());
    }

    function testGasMultiInput() public {
        (
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[] memory inputs
        ) = getMultiInputProof();

        uint g = gasleft();
        huffMultiInputVerifier.verify(a, b, c, inputs);
        emit log_named_uint("gas", g - gasleft());

        g = gasleft();
        solMultiInputVerifier.verifyProof(a, b, c, inputs);
        emit log_named_uint("gas", g - gasleft());
    }

    ////////////////////////////////////////////////////////////////
    //                        EC OPS TESTS                        //
    ////////////////////////////////////////////////////////////////

    function testNegate() public {
        Pairing.G1Point memory point = Pairing.G1Point(1, 2);
        Pairing.G1Point memory solRes = Pairing.negate(point);
        Pairing.G1Point memory huffRes = huffSingleInputVerifier.negate(point);

        assertEq(abi.encode(solRes), hex"000000000000000000000000000000000000000000000000000000000000000130644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd45");
        assertEq(abi.encode(solRes), abi.encode(huffRes));
    }

    function testAdd() public {
        Pairing.G1Point memory a = Pairing.G1Point(1, 2);
        Pairing.G1Point memory b = Pairing.G1Point(1, 2);
        Pairing.G1Point memory solRes = Pairing.addition(a, b);       
        Pairing.G1Point memory huffRes = huffSingleInputVerifier.addition(a, b);       

        assertEq(abi.encode(solRes), hex"030644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd315ed738c0e0a7c92e7845f96b2ae9c0a68a6a449e3538fc7ff3ebf7a5a18a2c4");
        assertEq(abi.encode(solRes), abi.encode(huffRes));
    }

    function testScalarMul() public {
        Pairing.G1Point memory a = Pairing.G1Point(1, 2);
        uint s = 2;
        Pairing.G1Point memory solRes = Pairing.scalar_mul(a, s);       
        Pairing.G1Point memory huffRes = huffSingleInputVerifier.scalar_mul(a, s);       

        assertEq(abi.encode(solRes), hex"030644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd315ed738c0e0a7c92e7845f96b2ae9c0a68a6a449e3538fc7ff3ebf7a5a18a2c4");
        assertEq(abi.encode(solRes), abi.encode(huffRes));
    }

    ////////////////////////////////////////////////////////////////
    //                     VERIFICATION TESTS                     //
    ////////////////////////////////////////////////////////////////

    function testVerifySingleInputProof() public {
        (
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[] memory inputs
        ) = getSingleInputProof();

        assertEq(solSingleInputVerifier.verifyProof(a, b, c, inputs), true);
        assertEq(huffSingleInputVerifier.verify(a, b, c, inputs), true);
    }

    function testVerifyMultiInputProof() public {
        (
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[] memory inputs
        ) = getMultiInputProof();

        assertEq(solMultiInputVerifier.verifyProof(a, b, c, inputs), true);
        assertEq(huffMultiInputVerifier.verify(a, b, c, inputs), true);
    }

    ////////////////////////////////////////////////////////////////
    //                          HELPERS                           //
    ////////////////////////////////////////////////////////////////

    function getSingleInputProof() internal pure returns(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[] memory inputs) {
        a = [
            0x0fa55097071458e4e105175cafdd75c0b4c6f639227db56ab908050dc99c6220,
            0x0ac50ef419a1e1f29f5ff0d1898af514a36bc42ba970fd503060a6123c6d8f6c
        ];
        b = [
            [
                0x23cfed79e17316667872d9377d23c9553321bf162b566facf05f262fe1a534ca,
                0x0a658672d02e119820017f116b913ec347182ba17b24416b683bee1d07a200db
            ],
            [
                0x2c9661cac208dc71f2b5f48f4ed82b224056fb2fba1ff9792ec96bf3ea9a6f92,
                0x1c8e9ccb3fffcda4e6df7f2fa8f8f767c3fb868493d36788df6977f1001802f7
            ]
        ];
        c = [
            0x2038751350aad5781c0e5c1f245d75d6ea198ca6bc42440ae1fc74ee99841921,
            0x06ab85db3cf7d039bb4da84c2d6137ff93c3490a79146548949d1531a3455353
        ];

        uint[] memory _inputs = new uint[](1);
        _inputs[0] = uint(182377969136052884622247920755931704678273168534);
        inputs = _inputs;
    }

    function getMultiInputProof() internal pure returns(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[] memory inputs) {
        a = [
            0x2aa70aa50458b979bb6a9acd311e79a698774b277275792a82e130d11cc09e4f,
            0x1303403ffdfc74014c995f53f019af549cc4625ba3f65d8afd8d042c6675fb80
        ];
        b = [
            [
                0x1410f00e96f379b89da7247657af8199301dc1bb7629a62590b291e0b0353fbf,
                0x25c3b518be24a6013c7884edac6c11ddf2784686b4f213d9cb71a8dcf3268208
            ],
            [
                0x21b7d93afec38c2271a03349667375eeac8299d9a5333071a75b607e460a29a7,
                0x2f756f7d9a1c1489c61b2de7c77f91422ef1084d780c61689878f53d0fa55d69
            ]
        ];
        c = [
            0x2de6d5787e6c37cede6aea9871cada9b48a2bf7b67804ad51a4110276994dfac,
            0x277c39d9eb95cbc274416bc0d3447c52d75e85b339aa26daeb6892a7b2119e90
        ];

        uint[] memory _inputs = new uint[](2);
        _inputs[0] = uint(171113707538181814873054780811642090348409570981);
        _inputs[1] = uint(1);
        inputs = _inputs;
    }
}
