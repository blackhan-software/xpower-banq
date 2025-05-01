// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {PowLimitedLib} from "../../source/library/modifier/PowLimited.sol";
import {Test} from "forge-std/Test.sol";

contract PowLimitedLibTest is Test {
    using PowLimitedLib for bytes32;

    function test_zeros_max() public pure {
        bytes32 hashed = bytes32(
            0x0000000000000000000000000000000000000000000000000000000000000000
        );
        assertEq(hashed.zeros(), 64);
    }

    function test_zeros_lhs() public pure {
        bytes32 hashed = bytes32(
            0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff
        );
        assertEq(hashed.zeros(), 32);
    }

    function test_zeros_rhs() public pure {
        bytes32 hashed = bytes32(
            0xffffffffffffffffffffffffffffffff00000000000000000000000000000000
        );
        assertEq(hashed.zeros(), 0);
    }

    function test_zeros_min() public pure {
        bytes32 hashed = bytes32(
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
        assertEq(hashed.zeros(), 0);
    }

    function test_zeros(bytes32 hashed) public pure {
        assertLe(hashed.zeros(), 64);
        assertGe(hashed.zeros(), 0);
    }
}
