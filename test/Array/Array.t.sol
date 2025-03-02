// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {Array} from "../../source/library/Array.sol";
import {Test} from "forge-std/Test.sol";

contract ArrayTest is Test {
    using Array for uint256[];

    /// forge-config: default.allow_internal_expect_revert = true
    function test_0() public {
        uint256[] memory array = new uint256[](0);
        vm.expectRevert(Array.Empty.selector);
        array.mean();
    }

    function test_1a() public pure {
        uint256[] memory array = new uint256[](1);
        assertEq(array.mean(), 0);
    }

    function test_1b() public pure {
        uint256[] memory array = new uint256[](1);
        array[0] = 1;
        assertEq(array.mean(), 1);
    }

    function test_1c() public pure {
        uint256[] memory array = new uint256[](1);
        array[0] = type(uint256).max;
        assertEq(array.mean(), type(uint256).max);
    }

    function test_1d() public pure {
        uint256[] memory array = new uint256[](1);
        array[0] = type(uint256).max - 1;
        assertEq(array.mean(), type(uint256).max - 1);
    }

    function test_2a() public pure {
        uint256[] memory array = new uint256[](2);
        assertEq(array.mean(), 0);
    }

    function test_2b() public pure {
        uint256[] memory array = new uint256[](2);
        array[0] = 1;
        array[1] = 2;
        assertEq(array.mean(), 1);
    }

    function test_2c() public pure {
        uint256[] memory array = new uint256[](2);
        array[0] = type(uint256).max;
        array[1] = type(uint256).max;
        assertEq(array.mean(), type(uint256).max);
    }

    function test_2d() public pure {
        uint256[] memory array = new uint256[](2);
        array[0] = type(uint256).max - 1;
        array[1] = type(uint256).max - 2;
        assertEq(array.mean(), type(uint256).max - 2);
    }

    function test_3a() public pure {
        uint256[] memory array = new uint256[](3);
        assertEq(array.mean(), 0);
    }

    function test_3b() public pure {
        uint256[] memory array = new uint256[](3);
        array[0] = 1;
        array[1] = 2;
        array[2] = 3;
        assertEq(array.mean(), 2);
    }

    function test_3c() public pure {
        uint256[] memory array = new uint256[](3);
        array[0] = type(uint256).max;
        array[1] = type(uint256).max;
        array[2] = type(uint256).max;
        assertEq(array.mean(), type(uint256).max);
    }

    function test_3d() public pure {
        uint256[] memory array = new uint256[](3);
        array[0] = type(uint256).max - 1;
        array[1] = type(uint256).max - 2;
        array[2] = type(uint256).max - 3;
        assertEq(array.mean(), type(uint256).max - 2);
    }
}
