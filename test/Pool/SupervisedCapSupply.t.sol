// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {IPool} from "../../source/interface/Pool.sol";
import {PoolTest} from "./Pool.t.sol";

contract TestBase is PoolTest {
    constructor() PoolTest(TOKENS, VAULT_FEE, IR_MODEL, DELPHI) {}

    function assert_cap(uint256 cap, uint256 dt) internal view {
        (uint256 all_cap, uint256 all_dt) = pool.capSupply(AVAX);
        assertEq(all_cap, cap);
        assertEq(all_dt, dt);
    }

    function assert_cup(uint256 cap, uint256 dt) internal view {
        (uint256 own_cap, uint256 own_dt) = pool.capSupplyOf(self, AVAX);
        assertEq(own_cap, cap);
        assertEq(own_dt, dt);
    }

    uint256 constant MAX = type(uint224).max;
}

contract SupervisedCapSupply is TestBase {
    function test_capSupply() public view {
        assert_cap(MAX, 0);
    }

    function test_capSupplyOf() public view {
        assert_cup(MAX, 0);
    }
}

contract SupervisedCapSupply_Only is TestBase {
    function setUp() public {
        acma.grantRole(acma.POOL_CAP_SUPPLY_ROLE(), self, 0);
    }

    function test_capSupply(uint224 cap) public {
        pool.capSupply(AVAX, cap);
    }
}

contract SupervisedCapSupply_Event is TestBase {
    function setUp() public {
        acma.grantRole(acma.POOL_CAP_SUPPLY_ROLE(), self, 0);
    }

    function test_capSupply() public {
        vm.expectEmit();
        emit CapSupply(AVAX, 1, 0);
        pool.capSupply(AVAX, 1);
    }

    event CapSupply(IERC20 indexed, uint256, uint256);
}

contract SupervisedCapSupply_NotEnlisted is TestBase {
    function setUp() public {
        acma.grantRole(acma.POOL_CAP_SUPPLY_ROLE(), self, 0);
    }

    function test_capSupply() public {
        vm.expectRevert(
            abi.encodeWithSelector(IPool.NotEnlisted.selector, T18)
        );
        pool.capSupply(T18, 1);
        vm.expectRevert(
            abi.encodeWithSelector(IPool.NotEnlisted.selector, T18)
        );
        pool.capSupply(T18);
        vm.expectRevert(
            abi.encodeWithSelector(IPool.NotEnlisted.selector, T18)
        );
        pool.capSupplyOf(self, T18);
    }
}

contract SupervisedCapSupply_Unauthorized is TestBase {
    function setUp() public {
        acma.revokeRole(acma.POOL_CAP_SUPPLY_ROLE(), self);
    }

    function testRevert_capSupply() public {
        vm.expectRevert(abi.encodeWithSelector(AM_UNAUTHORIZED, self));
        pool.capSupply(AVAX, 1);
    }

    function test_capSupply() public view {
        assert_cap(MAX, 0);
    }

    function test_capSupplyOf() public view {
        assert_cup(MAX, 0);
    }
}
