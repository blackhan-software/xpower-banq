// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {SupplyPosition} from "../../source/contract/Position.sol";
import {BorrowPosition} from "../../source/contract/Position.sol";
import {IRModel} from "../../source/struct/IRModel.sol";
import {VaultFee} from "../../source/struct/VaultFee.sol";
import {BaseTest} from "./Base.t.sol";

contract Scenario_001Test is BaseTest {
    constructor() BaseTest(VAULT_NIL, IR_MODEL) {}

    function setUp() public {
        supply.cap(1.0e18 ** 2, 0);
        borrow.cap(0.9e18 ** 2, 0);
        supply.mint(self, 1.0e18, false);
        borrow.mint(self, 0.9e18, false);
    }

    function test_setup() public view {
        assertEq(supply.balanceOf(self), 1.0e18);
        assertEq(borrow.balanceOf(self), 0.9e18);
        assertEq(supply.totalOf(self), 1.0e18);
        assertEq(borrow.totalOf(self), 0.9e18);
    }

    /**
     * Scenario: 1E18 supply, 9E17 borrow, 12 months
     */
    function test_S1E18_B9E17_12Ma() public {
        skip(12 * MONTH);
        ///
        assertEq(supply.balanceOf(self), 1.000000_000000_000000e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.105170_918075_647624e18);
        assertEq(borrow.totalOf(self), 0.994653_826268_082861e18);
        ///
        assertTrue(supply.transfer(self, 0.0e18)); // with interest!
        ///
        assertEq(supply.balanceOf(self), 1.105170_918075_647624e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.105170_918075_647624e18);
        assertEq(borrow.totalOf(self), 0.985233_338630_145102e18);
    }

    function test_S1E18_B9E17_12Mb() public {
        skip(12 * MONTH);
        ///
        assertEq(supply.balanceOf(self), 1.000000_000000_000000e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.105170_918075_647624e18);
        assertEq(borrow.totalOf(self), 0.994653_826268_082861e18);
        ///
        supply.approve(self, 0.0e18); // with interest accrual!
        assertTrue(supply.transferFrom(self, self, 0.0e18));
        ///
        assertEq(supply.balanceOf(self), 1.105170_918075_647624e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.105170_918075_647624e18);
        assertEq(borrow.totalOf(self), 0.985233_338630_145102e18);
    }

    /**
     * Scenario: 1E18 supply, 9E17 borrow, 6 months
     */
    function test_S1E18_B9E17_6Ma() public {
        skip(6 * MONTH);
        ///
        assertEq(supply.balanceOf(self), 1.000000_000000_000000e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.051271_096376_024039e18);
        assertEq(borrow.totalOf(self), 0.946143_986738_421635e18);
        ///
        assertTrue(supply.transfer(self, 0.5e18)); // with interest!
        assertTrue(supply.transfer(self, 0.5e18)); // idempotent op
        ///
        assertEq(supply.balanceOf(self), 1.051271_096376_024039e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.051271_096376_024039e18);
        assertEq(borrow.totalOf(self), 0.943839_598202_283145e18);
    }

    function test_S1E18_B9E17_6Mb() public {
        skip(6 * MONTH);
        ///
        assertEq(supply.balanceOf(self), 1.000000_000000_000000e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.051271_096376_024039e18);
        assertEq(borrow.totalOf(self), 0.946143_986738_421635e18);
        ///
        supply.approve(self, 0.5e18); // with interest accrual!
        assertTrue(supply.transferFrom(self, self, 0.5e18));
        supply.approve(self, 0.5e18); // idempotent operation
        assertTrue(supply.transferFrom(self, self, 0.5e18));
        ///
        assertEq(supply.balanceOf(self), 1.051271_096376_024039e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.051271_096376_024039e18);
        assertEq(borrow.totalOf(self), 0.943839_598202_283145e18);
    }

    /**
     * Scenario: 1E18 supply, 9E17 borrow, 3 months
     */
    function test_S1E18_B9E17_3Ma() public {
        skip(3 * MONTH);
        ///
        assertEq(supply.balanceOf(self), 1.000000_000000_000000e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.025315_120524_428840e18);
        assertEq(borrow.totalOf(self), 0.922783_608471_985956e18);
        ///
        assertTrue(supply.transfer(self, 1.0e18)); // with interest!
        assertTrue(supply.transfer(self, 1.0e18)); // idempotent op
        assertTrue(supply.transfer(self, 1.0e18)); // idempotent op
        ///
        assertEq(supply.balanceOf(self), 1.025315_120524_428840e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.025315_120524_428840e18);
        assertEq(borrow.totalOf(self), 0.922214_194014_428346e18);
    }

    function test_S1E18_B9E17_3Mb() public {
        skip(3 * MONTH);
        ///
        assertEq(supply.balanceOf(self), 1.000000_000000_000000e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.025315_120524_428840e18);
        assertEq(borrow.totalOf(self), 0.922783_608471_985956e18);
        ///
        supply.approve(self, 1.0e18); // with interest accrual!
        assertTrue(supply.transferFrom(self, self, 1.0e18));
        supply.approve(self, 1.0e18); // idempotent operation
        assertTrue(supply.transferFrom(self, self, 1.0e18));
        supply.approve(self, 1.0e18); // idempotent operation
        assertTrue(supply.transferFrom(self, self, 1.0e18));
        ///
        assertEq(supply.balanceOf(self), 1.025315_120524_428840e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.025315_120524_428840e18);
        assertEq(borrow.totalOf(self), 0.922214_194014_428346e18);
    }
}
