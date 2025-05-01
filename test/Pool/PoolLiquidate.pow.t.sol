// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {PowLimitedLib} from "../../source/contract/modifier/PowLimited.sol";
import {IPowLimited} from "../../source/contract/modifier/PowLimited.sol";
import {IPool} from "../../source/interface/Pool.sol";
import {PoolTest} from "./Pool.t.sol";

contract TestBase is PoolTest {
    constructor() PoolTest(TOKENS, VAULT_NIL, IR_MODEL, DELPHI) {}

    function setUp() public virtual {
        acma.grantRole(acma.POOL_SQUARE_ROLE(), address(pool), 0);
        acma.grantRole(acma.POOL_SET_TARGET_ROLE(), self, 0);
        pool.setTarget(pool.POW_SQUARE_ID(partial_exp), 1);
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

    uint8 internal constant partial_exp = 3; // 12.5%
}

contract PoolLiquidate_PoW is TestBase {
    using PowLimitedLib for bytes32;

    function test_liquidate_pass(uint256 n) public {
        bytes memory args = abi.encodeWithSignature(
            "liquidate(address,uint8)",
            self, // victim address
            partial_exp, // 2^(-PE)
            n // PoW nonce
        );
        bytes32 hashed = pool.blockHash().key(tx.origin, args);
        if (hashed.zeros() < 1) {
            return; // ignore
        }
        vm.startPrank(papa);
        USDC.approve(address(pool), bUSDC.totalOf(self));
        AVAX.approve(address(pool), sAVAX.totalOf(self));
        (bool ok, bytes memory data) = address(pool).call(args);
        vm.stopPrank();
        assertEq(data.length, 0);
        assertTrue(ok);
    }

    function test_liquidate_fail(uint256 n) public {
        bytes memory args = abi.encodeWithSignature(
            "liquidate(address,uint8)",
            self, // victim address
            partial_exp, // 2^(-PE)
            n // PoW nonce
        );
        bytes32 hashed = pool.blockHash().key(tx.origin, args);
        if (hashed.zeros() > 0) {
            return; // ignore
        }
        vm.startPrank(papa);
        USDC.approve(address(pool), bUSDC.totalOf(self));
        AVAX.approve(address(pool), sAVAX.totalOf(self));
        vm.expectPartialRevert(IPowLimited.PowLimited.selector);
        (bool ok, bytes memory data) = address(pool).call(args);
        assertEq(data.length, 8192);
        assertTrue(ok);
        vm.stopPrank();
    }
}
