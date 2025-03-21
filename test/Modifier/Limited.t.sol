// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {ILimited} from "../../source/contract/modifier/Limited.sol";
import {Limited} from "../../source/contract/modifier/Limited.sol";
import {Test} from "forge-std/Test.sol";

contract LimitTest is Limited, Test {
    uint256 immutable BLK_STAMP = block.timestamp;
    uint256 constant DURATION = 1 hours;

    function by(uint256 dt) internal view returns (uint256) {
        return block.timestamp + dt;
    }

    function assertLimit(
        bytes32 key,
        uint256 duration,
        bool pending
    ) internal view {
        (uint256 d, bool p) = limitedOf(key);
        assertEq(d, duration);
        assertEq(p, pending);
    }

    function funny1(
        uint256 arg1
    ) public limited(DURATION, keyOf(this.funny1.selector, abi.encode(arg1))) {
        assertGt(block.timestamp, 0);
        emit Invoke(arg1);
    }

    function funny2(
        uint256 arg1,
        uint256 arg2
    )
        public
        limited(DURATION, keyOf(this.funny2.selector, abi.encode(arg1, arg2)))
    {
        assertGt(block.timestamp, 0);
        emit Invoke(arg1, arg2);
    }

    function keyOf(
        bytes4 selector,
        bytes memory args
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(selector, args));
    }

    bytes4 immutable LIMITED = ILimited.Limited.selector;
    event Invoke(uint256 arg1, uint256 arg2);
    event Invoke(uint256 arg1);
}

contract LimitTest1 is LimitTest {
    function test_funny(uint256 arg1) public {
        bytes32 key = keyOf(this.funny1.selector, abi.encode(arg1));
        ///
        vm.expectEmit();
        emit Invoke(arg1);
        assertLimit(key, BLK_STAMP, false);
        funny1(arg1); // invoked
        assertLimit(key, 1.0 hours, true);
        ///
        vm.warp(by(30 minutes));
        assertLimit(key, 0.5 hours, true);
        vm.warp(by(30 minutes));
        ///
        vm.expectEmit();
        emit Invoke(arg1);
        assertLimit(key, 0, false);
        funny1(arg1); // invoked
        assertLimit(key, 1.0 hours, true);
    }
}

contract LimitTest2 is LimitTest {
    function test_funny(uint256 arg1, uint256 arg2) public {
        bytes32 key = keyOf(this.funny2.selector, abi.encode(arg1, arg2));
        ///
        vm.expectEmit();
        emit Invoke(arg1, arg2);
        assertLimit(key, BLK_STAMP, false);
        funny2(arg1, arg2); // invoked
        assertLimit(key, 1.0 hours, true);
        ///
        vm.warp(by(30 minutes));
        assertLimit(key, 0.5 hours, true);
        vm.warp(by(30 minutes));
        ///
        vm.expectEmit();
        emit Invoke(arg1, arg2);
        assertLimit(key, 0, false);
        funny2(arg1, arg2); // invoked
        assertLimit(key, 1.0 hours, true);
    }
}

contract LimitTest1_Limited is LimitTest {
    /// forge-config: default.allow_internal_expect_revert = true
    function test_funny(uint256 arg1) public {
        bytes32 key = keyOf(this.funny1.selector, abi.encode(arg1));
        ///
        assertLimit(key, BLK_STAMP, false);
        funny1(arg1); // invoked
        assertLimit(key, 1.0 hours, true);
        vm.expectRevert(abi.encodeWithSelector(LIMITED, key, 60 minutes));
        assertLimit(key, 1.0 hours, true);
        funny1(arg1); // invoked: not!
        assertLimit(key, 1.0 hours, true);
    }
}

contract LimitTest2_Limited is LimitTest {
    /// forge-config: default.allow_internal_expect_revert = true
    function test_funny(uint256 arg1, uint256 arg2) public {
        bytes32 key = keyOf(this.funny2.selector, abi.encode(arg1, arg2));
        ///
        assertLimit(key, BLK_STAMP, false);
        funny2(arg1, arg2); // invoked
        assertLimit(key, 1.0 hours, true);
        vm.expectRevert(abi.encodeWithSelector(LIMITED, key, 60 minutes));
        assertLimit(key, 1.0 hours, true);
        funny2(arg1, arg2); // invoked: not!
        assertLimit(key, 1.0 hours, true);
    }
}
