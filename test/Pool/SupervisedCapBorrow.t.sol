// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {IPool} from "../../source/interface/Pool.sol";
import {PoolTest} from "./Pool.t.sol";

contract TestBase is PoolTest {
    constructor() PoolTest(TOKENS, VAULT_FEE, IR_MODEL, DELPHI) {}

    function assert_cap(uint256 cap, uint256 dt) internal view {
        (uint256 all_cap, uint256 all_dt) = pool.capBorrow(AVAX);
        assertEq(all_cap, cap);
        assertEq(all_dt, dt);
    }

    function assert_cup(uint256 cap, uint256 dt) internal view {
        (uint256 own_cap, uint256 own_dt) = pool.capBorrowOf(self, AVAX);
        assertEq(own_cap, cap);
        assertEq(own_dt, dt);
    }

    uint256 constant MAX = type(uint224).max;
}

contract SupervisedCapBorrow is TestBase {
    function test_capBorrow() public view {
        assert_cap(MAX, 0);
    }

    function test_capBorrowOf() public view {
        assert_cup(MAX, 0);
    }
}

contract SupervisedCapBorrow_Only is TestBase {
    function setUp() public {
        acma.grantRole(acma.POOL_CAP_BORROW_ROLE(), self, 0);
    }

    function test_capBorrow(uint224 cap) public {
        pool.capBorrow(AVAX, cap);
    }
}

contract SupervisedCapBorrow_Event is TestBase {
    function setUp() public {
        acma.grantRole(acma.POOL_CAP_BORROW_ROLE(), self, 0);
    }

    function test_capBorrow() public {
        vm.expectEmit();
        emit CapBorrow(AVAX, 1, 0);
        pool.capBorrow(AVAX, 1);
    }

    event CapBorrow(IERC20 indexed, uint256, uint256);
}

contract SupervisedCapBorrow_NotEnlisted is TestBase {
    function setUp() public {
        acma.grantRole(acma.POOL_CAP_BORROW_ROLE(), self, 0);
    }

    function test_capBorrow() public {
        vm.expectRevert(
            abi.encodeWithSelector(IPool.NotEnlisted.selector, T18)
        );
        pool.capBorrow(T18, 1);
        vm.expectRevert(
            abi.encodeWithSelector(IPool.NotEnlisted.selector, T18)
        );
        pool.capBorrow(T18);
        vm.expectRevert(
            abi.encodeWithSelector(IPool.NotEnlisted.selector, T18)
        );
        pool.capBorrowOf(self, T18);
    }
}

contract SupervisedCapBorrow_Unauthorized is TestBase {
    function setUp() public {
        acma.revokeRole(acma.POOL_CAP_BORROW_ROLE(), self);
    }

    function testRevert_capBorrow() public {
        vm.expectRevert(abi.encodeWithSelector(AM_UNAUTHORIZED, self));
        pool.capBorrow(AVAX, 1);
    }

    function test_capBorrow() public view {
        assert_cap(MAX, 0);
    }

    function test_capBorrowOf() public view {
        assert_cup(MAX, 0);
    }
}
