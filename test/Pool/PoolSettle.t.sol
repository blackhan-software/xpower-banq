// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {SupplyPosition} from "../../source/contract/Position.sol";
import {BorrowPosition} from "../../source/contract/Position.sol";
import {IPool} from "../../source/interface/Pool.sol";
import {Health} from "../../source/struct/Health.sol";
import {Weight} from "../../source/struct/Weight.sol";
import {PoolTest} from "./Pool.t.sol";

contract TestBase is PoolTest {
    constructor() PoolTest(TOKENS, VAULT_FEE, IR_MODEL, DELPHI) {}
}

contract PoolSettle_Only is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 100 * ONE);
        pool.supply(AVAX, 50 * ONE);
        pool.supply(AVAX, 25 * ONE);
        pool.supply(AVAX, 25 * ONE);
        ///
        Weight memory weight = pool.weightOf(AVAX);
        uint256 supply = Math.mulDiv(
            sAVAX.balanceOf(self),
            weight.supply,
            weight.borrow
        );
        pool.borrow(AVAX, supply);
        ///
        _borrow = bAVAX.balanceOf(self);
        AVAX.approve(address(pool), _borrow);
    }

    function test_settle_only() public {
        pool.settle(AVAX, _borrow);
    }

    uint256 private _borrow;
}

contract PoolSettle_General is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 100 * ONE);
        pool.supply(AVAX, 50 * ONE);
        pool.supply(AVAX, 25 * ONE);
        pool.supply(AVAX, 25 * ONE);
        ///
        Weight memory weight = pool.weightOf(AVAX);
        uint256 supply = Math.mulDiv(
            sAVAX.balanceOf(self),
            weight.supply,
            weight.borrow
        );
        pool.borrow(AVAX, supply);
        ///
        uint256 borrow = bAVAX.balanceOf(self);
        AVAX.approve(address(pool), borrow);
        pool.settle(AVAX, borrow);
    }

    function test_balance_of_vault() public view {
        uint256 balance = 100.066576_495830_171830e18;
        assertEq(AVAX.balanceOf(address(vAVAX)), balance);
    }

    function test_balance_of_pool() public view {
        uint256 vavax = 99.643015_652806_634019_013436975e27;
        assertEq(vAVAX.balanceOf(address(pool)), vavax);
    }

    function test_balance_of_self() public view {
        uint256 balance = 899.933423_504169_828170e18;
        assertEq(AVAX.balanceOf(self), balance);
    }

    function test_supply_of_self() public view {
        uint256 supply = 99.964608_489003_001244e18;
        assertEq(sAVAX.balanceOf(self), supply);
    }

    function test_borrow_of_self() public view {
        assertEq(bAVAX.balanceOf(self), 0);
    }

    function test_health_of_self() public view {
        uint256 supply = 8_496.991721_565255_105740e18;
        Health memory health = pool.healthOf(self);
        assertEq(health.wnav_supply, supply);
        assertEq(health.wnav_borrow, 0);
    }
}

contract PoolSettle_Event is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 100 * ONE);
        pool.supply(AVAX, 50 * ONE);
        pool.supply(AVAX, 25 * ONE);
        pool.supply(AVAX, 25 * ONE);
        ///
        Weight memory weight = pool.weightOf(AVAX);
        uint256 supply = Math.mulDiv(
            sAVAX.balanceOf(self),
            weight.supply,
            weight.borrow
        );
        pool.borrow(AVAX, supply);
    }

    function test_settle() public {
        uint256 borrow = bAVAX.balanceOf(self);
        AVAX.approve(address(pool), borrow);
        vm.expectEmit();
        emit Settle(self, AVAX, borrow);
        uint256 amount = pool.settle(AVAX, borrow);
        assertEq(amount, 66.620820_128142_077869e18);
    }

    event Settle(address indexed, IERC20 indexed, uint256);
}

contract PoolSettle_NotEnlisted is TestBase {
    function test_settle() public {
        vm.expectRevert(
            abi.encodeWithSelector(IPool.NotEnlisted.selector, T18)
        );
        pool.settle(T18, ONE);
    }
}
