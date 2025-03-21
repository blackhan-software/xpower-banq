// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IPool} from "../../source/interface/Pool.sol";
import {Health} from "../../source/struct/Health.sol";
import {PoolTest} from "./Pool.t.sol";

contract TestBase is PoolTest {
    constructor() PoolTest(TOKENS, VAULT_FEE, IR_MODEL, DELPHI) {}
}

contract PoolRedeem_Only is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), ONE);
        pool.supply(AVAX, ONE);
        ///
        _supply = sAVAX.balanceOf(self);
    }

    function test_redeem_only() public {
        pool.redeem(AVAX, _supply);
    }

    uint256 private _supply;
}

contract PoolRedeem_General is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 100 * ONE);
        pool.supply(AVAX, 50 * ONE);
        pool.supply(AVAX, 25 * ONE);
        pool.supply(AVAX, 25 * ONE);
        ///
        uint256 supply = sAVAX.balanceOf(self);
        pool.redeem(AVAX, supply);
    }

    function test_balance_of_vault() public view {
        uint256 avax = 0.135256_254742_256501e18;
        assertEq(AVAX.balanceOf(address(vAVAX)), avax);
    }

    function test_balance_of_pool() public view {
        uint256 vavax = 0.035335_553962_780884_441885928e27;
        assertEq(vAVAX.balanceOf(address(pool)), vavax);
    }

    function test_balance_of_self() public view {
        uint256 avax = 999.864743_745257_743499e18;
        assertEq(AVAX.balanceOf(self), avax);
    }

    function test_vault_of_self() public view {
        assertEq(vAVAX.balanceOf(self), 0);
    }

    function test_supply_of_self() public view {
        assertEq(sAVAX.balanceOf(self), 0);
    }

    function test_borrow_of_self() public view {
        assertEq(bAVAX.balanceOf(self), 0);
    }

    function test_health_of_self() public view {
        Health memory health = pool.healthOf(self);
        assertEq(health.wnav_supply, 0);
        assertEq(health.wnav_borrow, 0);
    }
}

contract PoolRedeem_Event is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 100 * ONE);
        pool.supply(AVAX, 50 * ONE);
        pool.supply(AVAX, 25 * ONE);
        pool.supply(AVAX, 25 * ONE);
    }

    function test_redeem() public {
        uint256 supply = sAVAX.balanceOf(self);
        vm.expectEmit();
        emit Redeem(self, AVAX, supply);
        uint256 amount = pool.redeem(AVAX, supply);
        assertEq(amount, 99.864743_745257_743499e18);
    }

    event Redeem(address indexed, IERC20 indexed, uint256);
}

contract PoolRedeem_NotEnlisted is TestBase {
    function test_redeem() public {
        vm.expectRevert(
            abi.encodeWithSelector(IPool.NotEnlisted.selector, T18)
        );
        pool.redeem(T18, ONE);
    }
}
