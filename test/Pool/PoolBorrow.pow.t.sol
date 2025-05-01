// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {PowLimitedLib} from "../../source/contract/modifier/PowLimited.sol";
import {IPowLimited} from "../../source/contract/modifier/PowLimited.sol";
import {IFlash, IPool} from "../../source/interface/Pool.sol";
import {PoolTest} from "./Pool.t.sol";

contract TestBase is PoolTest {
    constructor() PoolTest(TOKENS, VAULT_NIL, IR_MODEL, DELPHI) {}
}

contract PoolBorrow_PoW is TestBase {
    using PowLimitedLib for bytes32;

    function setUp() public {
        acma.grantRole(acma.POOL_SET_TARGET_ROLE(), self, 0);
        pool.setTarget(pool.POW_BORROW_ID(AVAX), 1);
        AVAX.approve(address(pool), (3 * ONE) / 2);
        pool.supply(AVAX, (3 * ONE) / 2);
    }

    function test_borrow_pass(uint256 n) public {
        bytes memory args = abi.encodeWithSignature(
            "borrow(address,uint256)",
            AVAX, // token address
            ONE, // token amount
            n // PoW nonce
        );
        bytes32 hashed = pool.blockHash().key(tx.origin, args);
        if (hashed.zeros() < 1) {
            return; // ignore
        }
        vm.expectEmit();
        emit IPool.Borrow(self, AVAX, ONE, false, IFlash(address(0)), "");
        (bool ok, bytes memory data) = address(pool).call(args);
        uint256 amount = abi.decode(data, (uint256));
        assertEq(data.length, 32);
        assertEq(amount, ONE);
        assertTrue(ok);
    }

    function test_borrow_fail(uint256 n) public {
        bytes memory args = abi.encodeWithSignature(
            "borrow(address,uint256)",
            AVAX, // token address
            ONE, // token amount
            n // PoW nonce
        );
        bytes32 hashed = pool.blockHash().key(tx.origin, args);
        if (hashed.zeros() > 0) {
            return; // ignore
        }
        vm.expectPartialRevert(IPowLimited.PowLimited.selector);
        (bool ok, bytes memory data) = address(pool).call(args);
        assertEq(data.length, 8192);
        assertTrue(ok);
    }
}
