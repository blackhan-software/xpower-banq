// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
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
        AVAX.transfer(caca, 200 * AVAX_ONE);
        USDC.transfer(dada, 200 * USDC_ONE);
        USDC.transfer(papa, 200 * USDC_ONE);
        ///
        vm.startPrank(papa);
        USDC.approve(address(pool), 100 * USDC_ONE);
        pool.supply(USDC, 100 * USDC_ONE);
        vm.stopPrank();
        ///
        vm.startPrank(caca);
        AVAX.approve(address(pool), 100 * AVAX_ONE);
        pool.supply(AVAX, 100 * AVAX_ONE, true);
        pool.borrow(USDC, 66 * USDC_ONE, true);
        vm.stopPrank();
        ///
        /// 1.0 => 0.67 AVAX/USDC (drop!)
        ///
        set_avaxusdc(2, 3);
    }
}

contract PoolLiquidate_Only is PoolLiquidate {
    function setUp() public override {
        super.setUp();
        ///
        vm.startPrank(dada);
        USDC.approve(address(pool), bUSDC.totalOf(caca) >> 1);
        AVAX.approve(address(pool), sAVAX.totalOf(caca) >> 1);
        vm.stopPrank();
    }

    function test_liquid_only() public {
        vm.startPrank(dada);
        pool.liquidate(caca, 1);
        vm.stopPrank();
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

    function test_balance_of_caca() public view {
        assertEq(AVAX.balanceOf(caca), 100 * AVAX_ONE);
        assertEq(USDC.balanceOf(caca), 66 * USDC_ONE);
    }

    function test_balance_of_dada() public view {
        assertEq(AVAX.balanceOf(dada), 0);
        assertEq(USDC.balanceOf(dada), 200 * USDC_ONE);
    }

    function test_balance_of_papa() public view {
        assertEq(AVAX.balanceOf(papa), 0);
        assertEq(USDC.balanceOf(papa), 100 * USDC_ONE);
    }

    function test_supply_of_caca() public view {
        assertEq(sAVAX.balanceOf(caca), 100 * AVAX_ONE);
        assertEq(sUSDC.balanceOf(caca), 0);
        assertEq(sAVAX.totalOf(caca), 100 * AVAX_ONE);
        assertEq(sUSDC.totalOf(caca), 0);
    }

    function test_supply_of_dada() public view {
        assertEq(sAVAX.balanceOf(dada), 0);
        assertEq(sUSDC.balanceOf(dada), 0);
        assertEq(sAVAX.totalOf(dada), 0);
        assertEq(sUSDC.totalOf(dada), 0);
    }

    function test_supply_of_papa() public view {
        assertEq(sAVAX.balanceOf(papa), 0);
        assertEq(sUSDC.balanceOf(papa), 100 * USDC_ONE);
        assertEq(sAVAX.totalOf(papa), 0);
        assertEq(sUSDC.totalOf(papa), 100 * USDC_ONE);
    }

    function test_borrow_of_caca() public view {
        assertEq(bAVAX.balanceOf(caca), 0);
        assertEq(bUSDC.balanceOf(caca), 66 * USDC_ONE);
        assertEq(bAVAX.totalOf(caca), 0);
        assertEq(bUSDC.totalOf(caca), 66 * USDC_ONE);
    }

    function test_borrow_of_dada() public view {
        assertEq(bAVAX.balanceOf(dada), 0);
        assertEq(bUSDC.balanceOf(dada), 0);
        assertEq(bAVAX.totalOf(dada), 0);
        assertEq(bUSDC.totalOf(dada), 0);
    }

    function test_borrow_of_papa() public view {
        assertEq(bAVAX.balanceOf(papa), 0);
        assertEq(bUSDC.balanceOf(papa), 0);
        assertEq(bAVAX.totalOf(papa), 0);
        assertEq(bUSDC.totalOf(papa), 0);
    }

    function test_lock_of_caca() public view {
        assertEq(pool.supplyLockOf(caca, AVAX), 100 * AVAX_ONE);
        assertEq(pool.supplyLockOf(caca, USDC), 0);
        assertEq(pool.borrowLockOf(caca, AVAX), 0);
        assertEq(pool.borrowLockOf(caca, USDC), 66 * USDC_ONE);
    }

    function test_lock_of_dada() public view {
        assertEq(pool.supplyLockOf(dada, AVAX), 0);
        assertEq(pool.supplyLockOf(dada, USDC), 0);
        assertEq(pool.borrowLockOf(dada, AVAX), 0);
        assertEq(pool.borrowLockOf(dada, USDC), 0);
    }

    function test_lock_of_papa() public view {
        assertEq(pool.supplyLockOf(papa, AVAX), 0);
        assertEq(pool.supplyLockOf(papa, USDC), 0);
        assertEq(pool.borrowLockOf(papa, AVAX), 0);
        assertEq(pool.borrowLockOf(papa, USDC), 0);
    }

    function test_health_of_caca() public view {
        uint256 borrow = 12_622.500000_000000_000000e18;
        Health memory health = pool.healthOf(caca);
        assertEq(health.wnav_supply, 8_500 * AVAX_ONE);
        assertEq(health.wnav_borrow, borrow);
    }

    function test_health_of_dada() public view {
        Health memory health = pool.healthOf(dada);
        assertEq(health.wnav_supply, 0);
        assertEq(health.wnav_borrow, 0);
    }

    function test_health_of_papa() public view {
        Health memory health = pool.healthOf(papa);
        assertEq(health.wnav_supply, 12_750 * AVAX_ONE);
        assertEq(health.wnav_borrow, 0);
    }
}

contract PoolLiquidate_After is PoolLiquidate {
    function setUp() public override {
        super.setUp();
        ///
        vm.startPrank(dada);
        USDC.approve(address(pool), bUSDC.totalOf(caca) >> 1);
        AVAX.approve(address(pool), sAVAX.totalOf(caca) >> 1);
        vm.stopPrank();
        ///
        vm.startPrank(dada);
        pool.liquidate(caca, 1);
        vm.stopPrank();
    }

    function test_balance_of_vault() public view {
        assertEq(AVAX.balanceOf(address(vAVAX)), 100 * AVAX_ONE);
        assertEq(USDC.balanceOf(address(vUSDC)), 67 * USDC_ONE);
    }

    function test_balance_of_pool() public view {
        assertEq(vAVAX.balanceOf(address(pool)), 100e9 * AVAX_ONE);
        assertEq(vUSDC.balanceOf(address(pool)), 67e9 * USDC_ONE);
    }

    function test_balance_of_caca() public view {
        assertEq(AVAX.balanceOf(caca), 100 * AVAX_ONE);
        assertEq(USDC.balanceOf(caca), 66 * USDC_ONE);
    }

    function test_balance_of_dada() public view {
        assertEq(AVAX.balanceOf(dada), 0);
        assertEq(USDC.balanceOf(dada), 167 * USDC_ONE);
    }

    function test_balance_of_papa() public view {
        assertEq(AVAX.balanceOf(papa), 0);
        assertEq(USDC.balanceOf(papa), 100 * USDC_ONE);
    }

    function test_supply_of_caca() public view {
        assertEq(sAVAX.balanceOf(caca), 50 * AVAX_ONE);
        assertEq(sUSDC.balanceOf(caca), 0);
        assertEq(sAVAX.totalOf(caca), 50 * AVAX_ONE);
        assertEq(sUSDC.totalOf(caca), 0);
    }

    function test_supply_of_dada() public view {
        assertEq(sAVAX.balanceOf(dada), 50 * AVAX_ONE);
        assertEq(sUSDC.balanceOf(dada), 0);
        assertEq(sAVAX.totalOf(dada), 50 * AVAX_ONE);
        assertEq(sUSDC.totalOf(dada), 0);
    }

    function test_supply_of_papa() public view {
        assertEq(sAVAX.balanceOf(papa), 0);
        assertEq(sUSDC.balanceOf(papa), 100 * USDC_ONE);
        assertEq(sAVAX.totalOf(papa), 0);
        assertEq(sUSDC.totalOf(papa), 100 * USDC_ONE);
    }

    function test_borrow_of_caca() public view {
        assertEq(bAVAX.balanceOf(caca), 0);
        assertEq(bUSDC.balanceOf(caca), 33 * USDC_ONE);
        assertEq(bAVAX.totalOf(caca), 0);
        assertEq(bUSDC.totalOf(caca), 33 * USDC_ONE);
    }

    function test_borrow_of_dada() public view {
        assertEq(bAVAX.balanceOf(dada), 0);
        assertEq(bUSDC.balanceOf(dada), 0);
        assertEq(bAVAX.totalOf(dada), 0);
        assertEq(bUSDC.totalOf(dada), 0);
    }

    function test_borrow_of_papa() public view {
        assertEq(bAVAX.balanceOf(papa), 0);
        assertEq(bUSDC.balanceOf(papa), 0);
        assertEq(bAVAX.totalOf(papa), 0);
        assertEq(bUSDC.totalOf(papa), 0);
    }

    function test_lock_of_caca() public view {
        assertEq(pool.supplyLockOf(caca, AVAX), 50 * AVAX_ONE);
        assertEq(pool.supplyLockOf(caca, USDC), 0);
        assertEq(pool.borrowLockOf(caca, AVAX), 0);
        assertEq(pool.borrowLockOf(caca, USDC), 33 * USDC_ONE);
    }

    function test_lock_of_dada() public view {
        assertEq(pool.supplyLockOf(dada, AVAX), 50 * AVAX_ONE);
        assertEq(pool.supplyLockOf(dada, USDC), 0);
        assertEq(pool.borrowLockOf(dada, AVAX), 0);
        assertEq(pool.borrowLockOf(dada, USDC), 0);
    }

    function test_lock_of_papa() public view {
        assertEq(pool.supplyLockOf(papa, AVAX), 0);
        assertEq(pool.supplyLockOf(papa, USDC), 0);
        assertEq(pool.borrowLockOf(papa, AVAX), 0);
        assertEq(pool.borrowLockOf(papa, USDC), 0);
    }

    function test_health_of_caca() public view {
        uint256 supply = 4250.000000_000000_000000e18;
        uint256 borrow = 6311.250000_000000_000000e18;
        Health memory health = pool.healthOf(caca);
        assertEq(health.wnav_supply, supply);
        assertEq(health.wnav_borrow, borrow);
    }

    function test_health_of_dada() public view {
        uint256 supply = 4250.000000_000000_000000e18;
        Health memory health = pool.healthOf(dada);
        assertEq(health.wnav_supply, supply);
        assertEq(health.wnav_borrow, 0);
    }

    function test_health_of_papa() public view {
        Health memory health = pool.healthOf(papa);
        assertEq(health.wnav_supply, 12_750 * AVAX_ONE);
        assertEq(health.wnav_borrow, 0);
    }
}
