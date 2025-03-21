// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IPosition} from "../../source/interface/Position.sol";
import {IPool} from "../../source/interface/Pool.sol";
import {PoolTest} from "./Pool.t.sol";

contract TestBase is PoolTest {
    constructor() PoolTest(TOKENS, VAULT_FEE, IR_MODEL, DELPHI) {}
}

contract PoolLock is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 3 * ONE + 1);
        pool.supply(AVAX, 3 * ONE + 1, true);
        AVAX.approve(address(pool), 2 * ONE + 0);
        pool.borrow(AVAX, 2 * ONE + 0, true);
    }

    function test_supply_lock() public view {
        assertEq(pool.supplyLockOf(self, AVAX), 3 * ONE);
        assertEq(pool.supplyLockOf(zero, AVAX), 3 * ONE);
    }

    function test_borrow_lock() public view {
        assertEq(pool.borrowLockOf(self, AVAX), 2 * ONE);
        assertEq(pool.borrowLockOf(zero, AVAX), 2 * ONE);
    }

    function test_redeem() public {
        vm.expectRevert(abi.encodeWithSelector(LOCKED, self, 3 * ONE));
        assertEq(0, pool.redeem(AVAX, 3 * ONE));
    }

    function test_settle() public {
        vm.expectRevert(abi.encodeWithSelector(LOCKED, self, 2 * ONE));
        assertEq(0, pool.settle(AVAX, 2 * ONE));
    }

    bytes4 LOCKED = IPosition.Locked.selector;
}

contract PoolLock_Total is TestBase {
    function setUp() public {
        AVAX.transfer(papa, ONE);
        AVAX.transfer(caca, ONE);
        AVAX.transfer(dada, ONE);
        //
        vm.startPrank(papa);
        AVAX.approve(address(pool), ONE);
        pool.supply(AVAX, ONE, true);
        vm.stopPrank();
        //
        vm.startPrank(caca);
        AVAX.approve(address(pool), ONE);
        pool.supply(AVAX, ONE, true);
        vm.stopPrank();
        //
        vm.startPrank(dada);
        AVAX.approve(address(pool), ONE);
        pool.supply(AVAX, ONE, true);
        vm.stopPrank();
    }

    function test_lock_of_papa() public view {
        assertEq(pool.supplyLockOf(papa, AVAX), 0.999999_999999_999999e18);
        assertEq(pool.borrowLockOf(papa, AVAX), 0.000000_000000_000000e18);
    }

    function test_lock_of_caca() public view {
        assertEq(pool.supplyLockOf(caca, AVAX), 0.999500_249875_062468e18);
        assertEq(pool.borrowLockOf(papa, AVAX), 0.000000_000000_000000e18);
    }

    function test_lock_of_dada() public view {
        assertEq(pool.supplyLockOf(dada, AVAX), 0.999333_777481_678880e18);
        assertEq(pool.borrowLockOf(papa, AVAX), 0.000000_000000_000000e18);
    }

    function test_lock_of_total() public view {
        assertEq(pool.supplyLockOf(zero, AVAX), 2.998834_027356_741347e18);
        assertEq(pool.borrowLockOf(papa, AVAX), 0.000000_000000_000000e18);
    }
}

contract PoolLock_Transfer is TestBase {
    function setUp() public {
        AVAX.transfer(papa, ONE);
        AVAX.transfer(caca, ONE);
        AVAX.transfer(dada, ONE);
        //
        vm.startPrank(papa);
        AVAX.approve(address(pool), ONE);
        pool.supply(AVAX, ONE, true);
        vm.stopPrank();
        //
        vm.startPrank(caca);
        AVAX.approve(address(pool), ONE);
        pool.supply(AVAX, ONE, true);
        vm.stopPrank();
        //
        vm.startPrank(dada);
        AVAX.approve(address(pool), ONE);
        pool.supply(AVAX, ONE, true);
        vm.stopPrank();
        //
        vm.startPrank(papa);
        sAVAX.transfer(caca, ONE - 1);
        vm.stopPrank();
    }

    function test_lock_of_papa() public view {
        assertEq(pool.supplyLockOf(papa, AVAX), 0.000000_000000_000000e18);
        assertEq(pool.borrowLockOf(papa, AVAX), 0.000000_000000_000000e18);
    }

    function test_lock_of_caca() public view {
        assertEq(pool.supplyLockOf(caca, AVAX), 1.999500_249875_062467e18);
        assertEq(pool.borrowLockOf(papa, AVAX), 0.000000_000000_000000e18);
    }

    function test_lock_of_dada() public view {
        assertEq(pool.supplyLockOf(dada, AVAX), 0.999333_777481_678880e18);
        assertEq(pool.borrowLockOf(papa, AVAX), 0.000000_000000_000000e18);
    }

    function test_lock_of_total() public view {
        assertEq(pool.supplyLockOf(zero, AVAX), 2.998834_027356_741347e18);
        assertEq(pool.borrowLockOf(papa, AVAX), 0.000000_000000_000000e18);
    }
}

contract PoolLock_Yield_1x100 is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 100 * ONE);
        pool.supply(AVAX, 100 * ONE, true);
        pool.borrow(AVAX, 62.213904e18);
    }

    function test_redeem_yield() public {
        skip(12 * MONTH);
        ///
        uint256 total = sAVAX.totalOf(self);
        uint256 balance = sAVAX.balanceOf(self);
        assertGt(total, balance);
        uint256 yields = total - balance;
        assertEq(yields, 7.157181_869616_719499e18);
        uint256 amount = pool.redeem(AVAX, yields); // ok
        assertEq(amount, 7.150031_837778_940557e18);
    }
}

contract PoolLock_Yield_2x50 is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 100 * ONE);
        pool.supply(AVAX, 50 * ONE, true);
        pool.supply(AVAX, 50 * ONE, true);
        pool.borrow(AVAX, 62.198358e18);
    }

    function test_redeem_yield() public {
        skip(12 * MONTH);
        ///
        uint256 total = sAVAX.totalOf(self);
        uint256 balance = sAVAX.balanceOf(self);
        assertGt(total, balance);
        uint256 yields = total - balance;
        assertEq(yields, 7.155393_433005_750746e18);
        uint256 amount = pool.redeem(AVAX, yields); // ok
        assertEq(amount, 7.148245_187817_932812e18);
    }
}

contract PoolLock_Yield_4x25 is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 100 * ONE);
        pool.supply(AVAX, 25 * ONE, true);
        pool.supply(AVAX, 25 * ONE, true);
        pool.supply(AVAX, 25 * ONE, true);
        pool.supply(AVAX, 25 * ONE, true);
        pool.borrow(AVAX, 62.184113e18);
    }

    function test_redeem_yield() public {
        skip(12 * MONTH);
        ///
        uint256 total = sAVAX.totalOf(self);
        uint256 balance = sAVAX.balanceOf(self);
        assertGt(total, balance);
        uint256 yields = total - balance;
        assertEq(yields, 7.153754_668971_195906e18);
        uint256 amount = pool.redeem(AVAX, yields); // ok
        assertEq(amount, 7.146608_060910_285619e18);
    }
}
