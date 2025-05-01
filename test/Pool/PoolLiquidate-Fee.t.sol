// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {Health} from "../../source/struct/Health.sol";
import {PoolTest} from "./Pool.t.sol";

contract TestBase is PoolTest {
    constructor() PoolTest(TOKENS, VAULT_FEE, IR_MODEL, DELPHI) {}

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
        vm.startPrank(papa);
        USDC.approve(address(pool), 100 * USDC_ONE);
        pool.supply(USDC, 100 * USDC_ONE);
        vm.stopPrank();
        ///
        AVAX.approve(address(pool), 100 * AVAX_ONE);
        pool.supply(AVAX, 100 * AVAX_ONE);
        pool.borrow(USDC, 66 * USDC_ONE);
        ///
        /// 1.0 => 0.67 AVAX/USDC (drop!)
        ///
        set_avaxusdc(2, 3);
    }
}

contract PoolLiquidate_Before is PoolLiquidate {
    function test_balance_of_vault() public view {
        assertEq(AVAX.balanceOf(address(vAVAX)), 100 * AVAX_ONE);
        assertEq(USDC.balanceOf(address(vUSDC)), 34.065936e6);
    }

    function test_balance_of_pool() public view {
        assertEq(vAVAX.balanceOf(address(pool)), 99.900099_900099_900099e27);
        assertEq(vUSDC.balanceOf(address(pool)), 33.966033_659340_654000e15);
    }

    function test_balance_of_self() public view {
        assertEq(AVAX.balanceOf(self), 900 * AVAX_ONE);
        assertEq(USDC.balanceOf(self), 865.934064e6);
    }

    function test_balance_of_papa() public view {
        assertEq(AVAX.balanceOf(papa), 0);
        assertEq(USDC.balanceOf(papa), 100 * USDC_ONE);
    }

    function test_supply_of_self() public view {
        assertEq(sAVAX.balanceOf(self), 99.999999_999999_999999e18);
        assertEq(sUSDC.balanceOf(self), 0);
        assertEq(sAVAX.totalOf(self), 99.999999_999999_999999e18);
        assertEq(sUSDC.totalOf(self), 0);
    }

    function test_supply_of_papa() public view {
        assertEq(sAVAX.balanceOf(papa), 0);
        assertEq(sUSDC.balanceOf(papa), 99.999999e6);
        assertEq(sAVAX.totalOf(papa), 0);
        assertEq(sUSDC.totalOf(papa), 99.999999e6);
    }

    function test_borrow_of_self() public view {
        assertEq(bAVAX.balanceOf(self), 0);
        assertEq(bUSDC.balanceOf(self), 66 * USDC_ONE);
        assertEq(bAVAX.totalOf(self), 0);
        assertEq(bUSDC.totalOf(self), 66 * USDC_ONE);
    }

    function test_borrow_of_papa() public view {
        assertEq(bAVAX.balanceOf(papa), 0);
        assertEq(bUSDC.balanceOf(papa), 0);
        assertEq(bAVAX.totalOf(papa), 0);
        assertEq(bUSDC.totalOf(papa), 0);
    }

    function test_health_of_self() public view {
        uint256 supply = 8_499.999999_999999_999915e18;
        uint256 borrow = 12_622.500000_000000_000000e18;
        Health memory health = pool.healthOf(self);
        assertEq(health.wnav_supply, supply);
        assertEq(health.wnav_borrow, borrow);
    }

    function test_health_of_papa() public view {
        uint256 supply = 12_749.999872_500000_000000e18;
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
        assertEq(USDC.balanceOf(address(vUSDC)), 100.065936e6);
    }

    function test_balance_of_pool() public view {
        assertEq(vAVAX.balanceOf(address(pool)), 99.900099_900099_900099e27);
        assertEq(vUSDC.balanceOf(address(pool)), 99.706739_309715_676000e15);
    }

    function test_balance_of_self() public view {
        assertEq(AVAX.balanceOf(self), 900 * AVAX_ONE);
        assertEq(USDC.balanceOf(self), 865.934064e6);
    }

    function test_balance_of_papa() public view {
        assertEq(AVAX.balanceOf(papa), 0);
        assertEq(USDC.balanceOf(papa), 34 * USDC_ONE);
    }

    function test_supply_of_self() public view {
        assertEq(sAVAX.balanceOf(self), 0);
        assertEq(sUSDC.balanceOf(self), 0);
    }

    function test_supply_of_papa() public view {
        assertEq(sAVAX.balanceOf(papa), 99.999999_999999_999999e18);
        assertEq(sUSDC.balanceOf(papa), 99.999999e6);
    }

    function test_borrow_of_self() public view {
        assertEq(bAVAX.balanceOf(self), 0);
        assertEq(bUSDC.balanceOf(self), 0);
    }

    function test_borrow_of_papa() public view {
        assertEq(bAVAX.balanceOf(papa), 0);
        assertEq(bUSDC.balanceOf(papa), 0);
    }

    function test_health_of_self() public view {
        Health memory health = pool.healthOf(self);
        assertEq(health.wnav_supply, 0);
        assertEq(health.wnav_borrow, 0);
    }

    function test_health_of_papa() public view {
        uint256 supply = 21_249.999872_499999_999915e18;
        Health memory health = pool.healthOf(papa);
        assertEq(health.wnav_supply, supply);
        assertEq(health.wnav_borrow, 0);
    }
}
