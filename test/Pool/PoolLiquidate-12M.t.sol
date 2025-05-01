// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {Health} from "../../source/struct/Health.sol";
import {PoolTest} from "./Pool.t.sol";

contract TestBase is PoolTest {
    constructor() PoolTest(TOKENS, VAULT_NIL, IR_MODEL, DELPHI) {}

    function setUp() public virtual {
        acma.grantRole(acma.POOL_SQUARE_ROLE(), address(pool), 0);
    }
}

contract PoolLiquidate is TestBase {
    function setUp() public virtual override {
        super.setUp();
        ///
        USDC.transfer(papa, 200 * USDC_ONE);
        ///
        pool.capSupply(USDC, (100 * USDC_ONE) ** 2, 0);
        vm.prank(papa);
        USDC.approve(address(pool), 100 * USDC_ONE);
        vm.prank(papa);
        pool.supply(USDC, 100 * USDC_ONE);
        ///
        AVAX.approve(address(pool), 100 * AVAX_ONE);
        pool.capSupply(AVAX, (100 * AVAX_ONE) ** 2, 0);
        pool.supply(AVAX, 100 * AVAX_ONE);
        pool.capBorrow(USDC, (66 * USDC_ONE) ** 2, 0);
        pool.borrow(USDC, 66 * USDC_ONE);
        ///
        /// 1.0 => 0.67 AVAX/USDC (drop!)
        ///
        set_avaxusdc(2, 3);
        ///
        skip(12 * MONTH);
    }
}

contract PoolLiquidate_Before is PoolLiquidate {
    function test_balance_of_vault() public view {
        assertEq(AVAX.balanceOf(address(vAVAX)), 100 * AVAX_ONE);
        assertEq(USDC.balanceOf(address(vUSDC)), 34 * USDC_ONE);
    }

    function test_balance_of_pool() public view {
        assertEq(vAVAX.balanceOf(address(pool)), 100e9 * AVAX_ONE);
        assertEq(vUSDC.balanceOf(address(pool)), 34e9 * USDC_ONE);
    }

    function test_balance_of_self() public view {
        assertEq(AVAX.balanceOf(self), 900 * AVAX_ONE);
        assertEq(USDC.balanceOf(self), 866 * USDC_ONE);
    }

    function test_balance_of_papa() public view {
        assertEq(AVAX.balanceOf(papa), 0);
        assertEq(USDC.balanceOf(papa), 100 * USDC_ONE);
    }

    function test_supply_of_self() public view {
        assertEq(sAVAX.balanceOf(self), 100 * AVAX_ONE);
        assertEq(sUSDC.balanceOf(self), 0);
        assertEq(sAVAX.totalOf(self), 100 * AVAX_ONE);
        assertEq(sUSDC.totalOf(self), 0);
    }

    function test_supply_of_papa() public view {
        assertEq(sAVAX.balanceOf(papa), 0);
        assertEq(sUSDC.balanceOf(papa), 100 * USDC_ONE);
        assertEq(sAVAX.totalOf(papa), 0);
        assertEq(sUSDC.totalOf(papa), 107.608917e6);
    }

    function test_borrow_of_self() public view {
        assertEq(bAVAX.balanceOf(self), 0);
        assertEq(bUSDC.balanceOf(self), 66 * USDC_ONE);
        assertEq(bAVAX.totalOf(self), 0);
        assertEq(bUSDC.totalOf(self), 71.021885e6);
    }

    function test_borrow_of_papa() public view {
        assertEq(bAVAX.balanceOf(papa), 0);
        assertEq(bUSDC.balanceOf(papa), 0);
        assertEq(bAVAX.totalOf(papa), 0);
        assertEq(bUSDC.totalOf(papa), 0);
    }

    function test_health_of_self() public view {
        uint256 borrow = 13_582.935506_250000_000000e18;
        Health memory health = pool.healthOf(self);
        assertEq(health.wnav_supply, 8_500 * AVAX_ONE);
        assertEq(health.wnav_borrow, borrow);
    }

    function test_health_of_papa() public view {
        uint256 supply = 13_720.136917_500000_000000e18;
        Health memory health = pool.healthOf(papa);
        assertEq(health.wnav_supply, supply);
        assertEq(health.wnav_borrow, 0);
    }
}

contract PoolLiquidate_After is PoolLiquidate {
    function setUp() public override {
        super.setUp();
        ///
        vm.startPrank(papa);
        USDC.approve(address(pool), bUSDC.totalOf(self));
        AVAX.approve(address(pool), sAVAX.totalOf(self));
        pool.liquidate(self, 0);
        vm.stopPrank();
    }

    function test_balance_of_vault() public view {
        assertEq(AVAX.balanceOf(address(vAVAX)), 100 * AVAX_ONE);
        assertEq(USDC.balanceOf(address(vUSDC)), 105.021885e6);
    }

    function test_balance_of_pool() public view {
        assertEq(vAVAX.balanceOf(address(pool)), 100e9 * AVAX_ONE);
        assertEq(vUSDC.balanceOf(address(pool)), 105.021885e15);
    }

    function test_balance_of_self() public view {
        assertEq(AVAX.balanceOf(self), 900 * AVAX_ONE);
        assertEq(USDC.balanceOf(self), 866 * USDC_ONE);
    }

    function test_balance_of_papa() public view {
        assertEq(AVAX.balanceOf(papa), 0);
        assertEq(USDC.balanceOf(papa), 28.978115e6);
    }

    function test_supply_of_self() public view {
        assertEq(sAVAX.balanceOf(self), 0);
        assertEq(sUSDC.balanceOf(self), 0);
        assertEq(sAVAX.totalOf(self), 0);
        assertEq(sUSDC.totalOf(self), 0);
    }

    function test_supply_of_papa() public view {
        assertEq(sAVAX.balanceOf(papa), 100 * AVAX_ONE);
        assertEq(sUSDC.balanceOf(papa), 100 * USDC_ONE);
        assertEq(sAVAX.totalOf(papa), 100 * AVAX_ONE);
        assertEq(sUSDC.totalOf(papa), 100 * USDC_ONE);
    }

    function test_borrow_of_self() public view {
        assertEq(bAVAX.balanceOf(self), 0);
        assertEq(bUSDC.balanceOf(self), 0);
        assertEq(bAVAX.totalOf(self), 0);
        assertEq(bUSDC.totalOf(self), 0);
    }

    function test_borrow_of_papa() public view {
        assertEq(bAVAX.balanceOf(papa), 0);
        assertEq(bUSDC.balanceOf(papa), 0);
        assertEq(bAVAX.totalOf(papa), 0);
        assertEq(bUSDC.totalOf(papa), 0);
    }

    function test_health_of_self() public view {
        Health memory health = pool.healthOf(self);
        assertEq(health.wnav_supply, 0);
        assertEq(health.wnav_borrow, 0);
    }

    function test_health_of_papa() public view {
        uint256 supply = 21_250.000000_000000_000000e18;
        Health memory health = pool.healthOf(papa);
        assertEq(health.wnav_supply, supply);
        assertEq(health.wnav_borrow, 0);
    }
}
