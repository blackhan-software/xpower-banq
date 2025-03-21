// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IRateLimited} from "../../source/contract/modifier/RateLimited.sol";
import {RateLimited} from "../../source/contract/modifier/RateLimited.sol";
import {Test} from "forge-std/Test.sol";

contract RateLimitedTest is RateLimited, Test {
    uint256 constant MAX_CAPACITY = 24 hours;
    uint256 constant BASE_COST = 8 hours;

    function by(uint256 dt) internal view returns (uint256) {
        return block.timestamp + dt;
    }

    function assertLimit(
        bytes32 key,
        uint256 duration,
        bool pending
    ) internal view {
        (uint256 d, bool p) = ratelimitedOf(key);
        assertEq(d, duration);
        assertEq(p, pending);
    }

    function funny1(
        uint256 arg1
    )
        public
        ratelimited(
            MAX_CAPACITY,
            BASE_COST,
            keyOf(this.funny1.selector, abi.encode(arg1))
        )
    {
        assertGt(block.timestamp, 0);
        emit Invoke(arg1);
    }

    function funny2(
        uint256 arg1,
        uint256 arg2
    )
        public
        ratelimited(
            MAX_CAPACITY,
            BASE_COST,
            keyOf(this.funny2.selector, abi.encode(arg1, arg2))
        )
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

    bytes4 immutable LIMITED = IRateLimited.RateLimited.selector;
    event Invoke(uint256 arg1, uint256 arg2);
    event Invoke(uint256 arg1);
}

contract RateLimitedTest1 is RateLimitedTest {
    function test_funny(uint256 arg1) public {
        bytes32 key = keyOf(this.funny1.selector, abi.encode(arg1));
        ///
        vm.expectEmit();
        emit Invoke(arg1);
        assertLimit(key, 0.00 hours, false);
        funny1(arg1); // invoked
        assertLimit(key, 16.0 hours, false);
        funny1(arg1); // invoked
        assertLimit(key, 8.00 hours, false);
        funny1(arg1); // invoked
        assertLimit(key, 0.00 hours, true);
        ///
        vm.warp(by(2 hours));
        assertLimit(key, 0.00 hours, true);
        vm.warp(by(2 hours));
        assertLimit(key, 0.00 hours, true);
        vm.warp(by(2 hours));
        assertLimit(key, 0.00 hours, true);
        vm.warp(by(2 hours));
        assertLimit(key, 0.00 hours, false);
        vm.warp(by(16 hours));
        ///
        vm.expectEmit();
        emit Invoke(arg1);
        assertLimit(key, 0.00 hours, false);
        funny1(arg1); // invoked
        assertLimit(key, 16.0 hours, false);
        funny1(arg1); // invoked
        assertLimit(key, 8.00 hours, false);
        funny1(arg1); // invoked
        assertLimit(key, 0.00 hours, true);
    }
}

contract RateLimitedTest2 is RateLimitedTest {
    function test_funny(uint256 arg1, uint256 arg2) public {
        bytes32 key = keyOf(this.funny2.selector, abi.encode(arg1, arg2));
        ///
        vm.expectEmit();
        emit Invoke(arg1, arg2);
        assertLimit(key, 0.00 hours, false);
        funny2(arg1, arg2); // invoked
        assertLimit(key, 16.0 hours, false);
        funny2(arg1, arg2); // invoked
        assertLimit(key, 8.00 hours, false);
        funny2(arg1, arg2); // invoked
        assertLimit(key, 0.00 hours, true);
        ///
        vm.warp(by(2 hours));
        assertLimit(key, 0.00 hours, true);
        vm.warp(by(2 hours));
        assertLimit(key, 0.00 hours, true);
        vm.warp(by(2 hours));
        assertLimit(key, 0.00 hours, true);
        vm.warp(by(2 hours));
        assertLimit(key, 0.00 hours, false);
        vm.warp(by(16 hours));
        ///
        vm.expectEmit();
        emit Invoke(arg1, arg2);
        assertLimit(key, 0.00 hours, false);
        funny2(arg1, arg2); // invoked
        assertLimit(key, 16.0 hours, false);
        funny2(arg1, arg2); // invoked
        assertLimit(key, 8.00 hours, false);
        funny2(arg1, arg2); // invoked
        assertLimit(key, 0.00 hours, true);
    }
}

contract RateLimitedTest1_Limited is RateLimitedTest {
    /// forge-config: default.allow_internal_expect_revert = true
    function test_funny(uint256 arg1, uint256 dt) public {
        bytes32 key = keyOf(this.funny1.selector, abi.encode(arg1));
        dt = bound(dt, 1, 8 hours);
        ///
        assertLimit(key, 0.00 hours, false);
        funny1(arg1); // invoked
        assertLimit(key, 16.0 hours, false);
        funny1(arg1); // invoked
        assertLimit(key, 8.00 hours, false);
        funny1(arg1); // invoked
        assertLimit(key, 0.00 hours, true);
        ///
        vm.warp(by(8 hours - dt));
        vm.expectRevert(abi.encodeWithSelector(LIMITED, key, dt));
        funny1(arg1); // invoked: not!
        assertLimit(key, 0.00 hours, true);
    }
}

contract RateLimitedTest2_Limited is RateLimitedTest {
    /// forge-config: default.allow_internal_expect_revert = true
    function test_funny(uint256 arg1, uint256 arg2, uint256 dt) public {
        bytes32 key = keyOf(this.funny2.selector, abi.encode(arg1, arg2));
        dt = bound(dt, 1, 8 hours);
        ///
        assertLimit(key, 0.00 hours, false);
        funny2(arg1, arg2); // invoked
        assertLimit(key, 16.0 hours, false);
        funny2(arg1, arg2); // invoked
        assertLimit(key, 8.00 hours, false);
        funny2(arg1, arg2); // invoked
        assertLimit(key, 0.00 hours, true);
        ///
        vm.warp(by(8 hours - dt));
        vm.expectRevert(abi.encodeWithSelector(LIMITED, key, dt));
        funny2(arg1, arg2); // invoked: not!
        assertLimit(key, 0.00 hours, true);
    }
}
