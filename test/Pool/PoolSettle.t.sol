// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

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

    function supplyOf(
        address account,
        Weight memory weight
    ) internal view returns (uint256) {
        return
            Math.mulDiv(sAVAX.balanceOf(account), weight.supply, weight.borrow);
    }

    function borrowOf(address account) internal view returns (uint256) {
        return bAVAX.balanceOf(account);
    }

    uint256 immutable SUPPLY_AVAX = 100e18;
}

contract PoolSettle_Only is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), SUPPLY_AVAX);
        pool.supply(AVAX, SUPPLY_AVAX);
        pool.borrow(AVAX, supplyOf(self, pool.weightOf(AVAX)));
        AVAX.approve(address(pool), borrowOf(self));
        _borrow = borrowOf(self);
    }

    function test_settle_only() public {
        pool.settle(AVAX, _borrow);
    }

    uint256 private _borrow;
}

contract PoolSettle_General is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), SUPPLY_AVAX);
        pool.supply(AVAX, SUPPLY_AVAX);
        pool.borrow(AVAX, supplyOf(self, pool.weightOf(AVAX)));
        AVAX.approve(address(pool), borrowOf(self));
        pool.settle(AVAX, borrowOf(self));
    }

    function test_balance_of_vault() public view {
        uint256 balance = 100.066600_066600_066602e18;
        assertEq(AVAX.balanceOf(address(vAVAX)), balance);
    }

    function test_balance_of_pool() public view {
        uint256 vavax = 99.700897_308075_772676_289467591e27;
        assertEq(vAVAX.balanceOf(address(pool)), vavax);
    }

    function test_balance_of_self() public view {
        uint256 balance = 899.933399_933399_933398e18;
        assertEq(AVAX.balanceOf(self), balance);
    }

    function test_supply_of_self() public view {
        uint256 supply = 99.999999_999999_999999e18;
        assertEq(sAVAX.balanceOf(self), supply);
    }

    function test_borrow_of_self() public view {
        assertEq(bAVAX.balanceOf(self), 0.022244_377888_733534e18);
    }

    function test_health_of_self() public view {
        uint256 supply = 8_499.999999_999999_999915e18;
        uint256 borrow = 2.836158_180813_525585e18;
        Health memory health = pool.healthOf(self);
        assertEq(health.wnav_supply, supply);
        assertEq(health.wnav_borrow, borrow);
    }
}

contract PoolSettle_Event is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), SUPPLY_AVAX);
        pool.supply(AVAX, SUPPLY_AVAX);
        pool.borrow(AVAX, supplyOf(self, pool.weightOf(AVAX)));
    }

    function test_settle() public {
        AVAX.approve(address(pool), borrowOf(self));
        vm.expectEmit();
        emit Settle(self, AVAX, borrowOf(self));
        uint256 assets = pool.settle(AVAX, borrowOf(self));
        assertEq(assets, 66.644422_288777_933132e18);
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
