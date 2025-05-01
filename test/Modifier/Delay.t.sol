// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IDelayed} from "../../source/contract/modifier/Delayed.sol";
import {Delayed} from "../../source/contract/modifier/Delayed.sol";
import {Test} from "forge-std/Test.sol";

contract DelayTest is Delayed, Test {
    function by(uint256 dt) internal view returns (uint256) {
        return block.timestamp + dt;
    }

    function assertDelay(
        bytes32 key,
        uint256 duration,
        bool pending
    ) internal view {
        (uint256 d, bool p) = delayedOf(key);
        assertEq(d, duration);
        assertEq(p, pending);
    }

    function funny1(
        uint256 arg1
    )
        public
        delayed(60 minutes, keyOf(this.funny1.selector, abi.encode(arg1)))
    {
        assertGt(block.timestamp, 60 minutes);
        emit Invoke(arg1);
    }

    function funny2(
        uint256 arg1,
        uint256 arg2
    )
        public
        delayed(60 minutes, keyOf(this.funny2.selector, abi.encode(arg1, arg2)))
    {
        assertGt(block.timestamp, 60 minutes);
        emit Invoke(arg1, arg2);
    }

    function keyOf(
        bytes4 selector,
        bytes memory args
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(selector, args));
    }

    bytes4 immutable DELAYED = IDelayed.Delayed.selector;
    event Invoke(uint256 arg1, uint256 arg2);
    event Invoke(uint256 arg1);
}

contract DelayTest1 is DelayTest {
    function test_funny(uint256 arg1) public {
        bytes32 key = keyOf(this.funny1.selector, abi.encode(arg1));
        ///
        vm.expectEmit();
        emit IDelayed.Pending(key, by(60 minutes));
        assertDelay(key, 1, false);
        funny1(arg1); // pending
        assertDelay(key, 3600, true);
        ///
        vm.warp(by(60 minutes));
        ///
        vm.expectEmit();
        emit Invoke(arg1);
        assertDelay(key, 0, false);
        funny1(arg1); // invoked
        assertDelay(key, 3601, false);
    }
}

contract DelayTest2 is DelayTest {
    function test_funny(uint256 arg1, uint256 arg2) public {
        bytes32 key = keyOf(this.funny2.selector, abi.encode(arg1, arg2));
        ///
        vm.expectEmit();
        emit IDelayed.Pending(key, by(60 minutes));
        assertDelay(key, 1, false);
        funny2(arg1, arg2); // pending
        assertDelay(key, 3600, true);
        ///
        vm.warp(by(60 minutes));
        ///
        vm.expectEmit();
        emit Invoke(arg1, arg2);
        assertDelay(key, 0, false);
        funny2(arg1, arg2); // invoked
        assertDelay(key, 3601, false);
    }
}

contract DelayTest1_Delayed is DelayTest {
    /// forge-config: default.allow_internal_expect_revert = true
    function test_funny(uint256 arg1) public {
        bytes32 key = keyOf(this.funny1.selector, abi.encode(arg1));
        ///
        assertDelay(key, 1, false);
        funny1(arg1); // pending
        assertDelay(key, 3600, true);
        vm.expectRevert(abi.encodeWithSelector(DELAYED, key, 60 minutes));
        assertDelay(key, 3600, true);
        funny1(arg1); // invoked: not!
        assertDelay(key, 3600, true);
    }
}

contract DelayTest2_Delayed is DelayTest {
    /// forge-config: default.allow_internal_expect_revert = true
    function test_funny(uint256 arg1, uint256 arg2) public {
        bytes32 key = keyOf(this.funny2.selector, abi.encode(arg1, arg2));
        ///
        assertDelay(key, 1, false);
        funny2(arg1, arg2); // pending
        assertDelay(key, 3600, true);
        vm.expectRevert(abi.encodeWithSelector(DELAYED, key, 60 minutes));
        assertDelay(key, 3600, true);
        funny2(arg1, arg2); // invoked: not!
        assertDelay(key, 3600, true);
    }
}

contract DelayTest1_Pending is DelayTest {
    function test_funny(uint256 arg1) public {
        bytes32 key = keyOf(this.funny1.selector, abi.encode(arg1));
        ///
        vm.expectEmit();
        emit IDelayed.Pending(key, by(60 minutes));
        assertDelay(key, 1, false);
        funny1(arg1); // pending
        assertDelay(key, 3600, true);
        ///
        vm.warp(by(120 minutes + 1));
        ///
        vm.expectEmit();
        emit IDelayed.Pending(key, by(60 minutes));
        assertDelay(key, 3601, false);
        funny1(arg1); // pending
        assertDelay(key, 3600, true);
    }
}

contract DelayTest2_Pending is DelayTest {
    function test_funny(uint256 arg1, uint256 arg2) public {
        bytes32 key = keyOf(this.funny2.selector, abi.encode(arg1, arg2));
        ///
        vm.expectEmit();
        emit IDelayed.Pending(key, by(60 minutes));
        assertDelay(key, 1, false);
        funny2(arg1, arg2); // pending
        assertDelay(key, 3600, true);
        ///
        vm.warp(by(120 minutes + 1));
        ///
        vm.expectEmit();
        emit IDelayed.Pending(key, by(60 minutes));
        assertDelay(key, 3601, false);
        funny2(arg1, arg2); // pending
        assertDelay(key, 3600, true);
    }
}
