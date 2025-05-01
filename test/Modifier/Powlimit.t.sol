// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {PowLimitedLib} from "../../source/contract/modifier/PowLimited.sol";
import {IPowLimited} from "../../source/contract/modifier/PowLimited.sol";
import {PowLimited} from "../../source/contract/modifier/PowLimited.sol";
import {Test} from "forge-std/Test.sol";

contract PowLimitedTest is PowLimited(24 hours), Test {
    uint256 constant DIFFICULTY = 1;
    using PowLimitedLib for bytes32;

    function by(uint256 dt) internal view returns (uint256) {
        return block.timestamp + dt;
    }

    function funny1(uint256 arg1) public powlimited(DIFFICULTY) {
        emit Invoke(arg1);
    }

    function funny2(uint256 arg1, uint256 arg2) public powlimited(DIFFICULTY) {
        emit Invoke(arg1, arg2);
    }

    function nonce1(
        uint256 arg1,
        bool flag
    ) internal view returns (uint256, bytes32) {
        arg1 = bound(arg1, 0, type(uint128).max);
        bytes32 key;
        do {
            key = this.keyOf(this.funny1.selector, abi.encodePacked(++arg1));
        } while (
            (flag && key.zeros() < DIFFICULTY) ||
                (!flag && key.zeros() >= DIFFICULTY)
        );
        return (arg1, key);
    }

    function nonce2(
        uint256 arg1,
        uint256 arg2,
        bool flag
    ) internal view returns (uint256, uint256, bytes32) {
        arg2 = bound(arg2, 0, type(uint128).max);
        bytes32 key;
        do {
            key = this.keyOf(
                this.funny2.selector,
                abi.encodePacked(arg1, ++arg2)
            );
        } while (
            (flag && key.zeros() < DIFFICULTY) ||
                (!flag && key.zeros() >= DIFFICULTY)
        );
        return (arg1, arg2, key);
    }

    function keyOf(
        bytes4 selector,
        bytes memory args
    ) external view returns (bytes32) {
        return blockHash().key(tx.origin, abi.encodePacked(selector, args));
    }

    bytes4 immutable LIMITED = IPowLimited.PowLimited.selector;
    event Invoke(uint256 arg1, uint256 arg2);
    event Invoke(uint256 arg1);
}

contract PowLimitedTest1 is PowLimitedTest {
    function test_funny(uint256 arg1) public {
        (uint a, ) = nonce1(arg1, true);
        vm.roll(1);
        vm.expectEmit();
        vm.warp(by(24 hours));
        emit Invoke(a);
        this.funny1(a);
    }

    function test_funny_123(uint256 arg1) public {
        (uint a, ) = nonce1(arg1, true);
        // 1st invocation: pass
        vm.roll(1);
        vm.warp(by(20 minutes));
        this.funny1(a);
        // 2nd invocation: pass
        vm.roll(2);
        vm.warp(by(20 minutes));
        this.funny1(a);
        // 3rd invocation: pass
        vm.roll(3);
        vm.warp(by(20 minutes));
        this.funny1(a);
    }
}

contract PowLimitedTest2 is PowLimitedTest {
    function test_funny(uint256 arg1, uint256 arg2) public {
        (uint a, uint b, ) = nonce2(arg1, arg2, true);
        vm.roll(1);
        vm.expectEmit();
        vm.warp(by(24 hours));
        emit Invoke(a, b);
        this.funny2(a, b);
    }

    function test_funny_123(uint256 arg1, uint256 arg2) public {
        (uint a, uint b, ) = nonce2(arg1, arg2, true);
        // 1st invocation: pass
        vm.roll(1);
        vm.warp(by(20 minutes));
        this.funny2(a, b);
        // 2nd invocation: pass
        vm.roll(2);
        vm.warp(by(20 minutes));
        this.funny2(a, b);
        // 3rd invocation: pass
        vm.roll(3);
        vm.warp(by(20 minutes));
        this.funny2(a, b);
    }
}

contract PowLimitedTest1_Limited is PowLimitedTest {
    using PowLimitedLib for bytes32;

    function test_funny(uint256 arg1) public {
        (uint a, bytes32 key) = nonce1(arg1, false);
        vm.expectRevert(abi.encodeWithSelector(LIMITED, key, DIFFICULTY));
        this.funny1(a);
    }

    function test_funny_123(uint256 arg1) public {
        (uint a, bytes32 key1) = nonce1(arg1, true);
        // 1st invocation: pass
        vm.roll(1);
        vm.warp(by(60 minutes));
        this.funny1(a);
        // 2nd invocation: pass (key2 == key1)
        bytes32 key2 = this.keyOf(this.funny1.selector, abi.encodePacked(a));
        assertEq(key2, key1);
        vm.roll(2);
        vm.warp(by(60 minutes));
        this.funny1(a);
        // 3rd invocation: fail (key3 != key2)
        bytes32 key3 = this.keyOf(this.funny1.selector, abi.encodePacked(a));
        if (key3.zeros() < DIFFICULTY) {
            assertNotEq(key3, key2);
        } else {
            return; // ignore
        }
        vm.roll(3);
        vm.warp(by(60 minutes));
        vm.expectRevert(abi.encodeWithSelector(LIMITED, key3, DIFFICULTY));
        this.funny1(a);
    }
}

contract PowLimitedTest2_Limited is PowLimitedTest {
    using PowLimitedLib for bytes32;

    function test_funny(uint256 arg1, uint256 arg2) public {
        (uint a, uint b, bytes32 key) = nonce2(arg1, arg2, false);
        vm.expectRevert(abi.encodeWithSelector(LIMITED, key, DIFFICULTY));
        this.funny2(a, b);
    }

    function test_funny_123(uint256 arg1, uint256 arg2) public {
        (uint a, uint b, bytes32 key1) = nonce2(arg1, arg2, true);
        // 1st invocation: pass
        vm.roll(1);
        vm.warp(by(60 minutes));
        this.funny2(a, b);
        // 2nd invocation: pass (key2 == key1)
        bytes32 key2 = this.keyOf(this.funny2.selector, abi.encodePacked(a, b));
        assertEq(key2, key1);
        vm.roll(2);
        vm.warp(by(60 minutes));
        this.funny2(a, b);
        // 3rd invocation: fail (key3 != key2)
        bytes32 key3 = this.keyOf(this.funny2.selector, abi.encodePacked(a, b));
        if (key3.zeros() < DIFFICULTY) {
            assertNotEq(key3, key2);
        } else {
            return; // ignore
        }
        vm.roll(3);
        vm.warp(by(60 minutes));
        vm.expectRevert(abi.encodeWithSelector(LIMITED, key3, DIFFICULTY));
        this.funny2(a, b);
    }
}
