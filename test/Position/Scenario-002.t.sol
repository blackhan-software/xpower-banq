// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {SupplyPosition} from "../../source/contract/Position.sol";
import {BorrowPosition} from "../../source/contract/Position.sol";
import {IRModel} from "../../source/struct/IRModel.sol";
import {VaultFee} from "../../source/struct/VaultFee.sol";
import {BaseTest} from "./Base.t.sol";

contract Scenario_002Test is BaseTest {
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
     * Scenario: 1E18 supply, 9E17 borrow, 12 months,
     * with (empty) supply before (empty) borrow.
     */
    function S1E18_B9E17_12M_SB() public {
        skip(12 * MONTH);
        ///
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.balanceOf(self), 1.000000_000000_000000e18);
        assertEq(borrow.totalOf(self), 0.994653_826268_082861e18);
        assertEq(supply.totalOf(self), 1.105170_918075_647624e18);
        ///
        supply.burn(self, 0, false);
        ///
        assertEq(supply.balanceOf(self), 1.105170_918075_647624e18);
        assertEq(supply.totalOf(self), 1.105170_918075_647624e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(borrow.totalOf(self), 0.985233_338630_145102e18);
        ///
        borrow.burn(self, 0, false);
        ///
        assertEq(borrow.balanceOf(self), 0.985233_338630_145102e18);
        assertEq(supply.balanceOf(self), 1.105170_918075_647624e18);
        assertEq(borrow.totalOf(self), 0.985233_338630_145102e18);
        assertEq(supply.totalOf(self), 1.105170_918075_647624e18);
    }

    /**
     * Scenario: 1E18 supply, 9E17 borrow, 12x1 months,
     * with (empty) supply before (empty) borrow.
     */
    function S1E18_B9E17_12x1M_SB() public {
        for (uint256 i = 0; i < 12; i++) {
            supply.reindex();
            borrow.reindex();
            skip(MONTH);
            (uint256 supply_indexi, uint256 supply_dti) = supply.index();
            (uint256 borrow_indexi, uint256 borrow_dti) = borrow.index();
            assertGt(supply_indexi, 1.0e18);
            assertGt(borrow_indexi, 1.0e18);
            assertEq(supply_dti, MONTH);
            assertEq(borrow_dti, MONTH);
        }
        (uint256 supply_index, uint256 supply_dt) = borrow.index();
        (uint256 borrow_index, uint256 borrow_dt) = borrow.index();
        assertEq(supply_index, 1.105170_918075_647603e18);
        assertEq(borrow_index, 1.105170_918075_647603e18);
        assertEq(supply_dt, MONTH);
        assertEq(borrow_dt, MONTH);
        ///
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.balanceOf(self), 1.000000_000000_000000e18);
        assertEq(borrow.totalOf(self), 0.994653_826268_082842e18);
        assertEq(supply.totalOf(self), 1.105170_918075_647603e18);
        ///
        supply.burn(self, 0, false);
        ///
        assertEq(supply.balanceOf(self), 1.105170_918075_647603e18);
        assertEq(supply.totalOf(self), 1.105170_918075_647603e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(borrow.totalOf(self), 0.993865_357060_360090e18);
        ///
        borrow.burn(self, 0, false);
        ///
        assertEq(borrow.balanceOf(self), 0.993865_357060_360090e18);
        assertEq(supply.balanceOf(self), 1.105170_918075_647603e18);
        assertEq(borrow.totalOf(self), 0.993865_357060_360090e18);
        assertEq(supply.totalOf(self), 1.105170_918075_647603e18);
    }

    /**
     * Scenario: 1E18 supply, 9E17 borrow, 12 months,
     * with (empty) borrow before (empty) supply.
     */
    function S1E18_B9E17_12M_BS() public {
        skip(12 * MONTH);
        ///
        assertEq(supply.balanceOf(self), 1.000000_000000_000000e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.105170_918075_647624e18);
        assertEq(borrow.totalOf(self), 0.994653_826268_082861e18);
        ///
        borrow.burn(self, 0, false);
        ///
        assertEq(borrow.balanceOf(self), 0.994653_826268_082861e18);
        assertEq(borrow.totalOf(self), 0.994653_826268_082861e18);
        assertEq(supply.balanceOf(self), 1.000000_000000_000000e18);
        assertEq(supply.totalOf(self), 2.590586_858693_413656e18); //!
        ///
        supply.burn(self, 0, false);
        ///
        assertEq(supply.balanceOf(self), 2.590586_858693_413656e18); //!
        assertEq(borrow.balanceOf(self), 0.994653_826268_082861e18);
        assertEq(supply.totalOf(self), 2.590586_858693_413656e18); //!
        assertEq(borrow.totalOf(self), 0.994653_826268_082861e18);
    }

    /**
     * Scenario: 1E18 supply, 9E17 borrow, 12x1 months,
     * with (empty) borrow before (empty) supply.
     */
    function S1E18_B9E17_12x1M_BS() public {
        for (uint256 i = 0; i < 12; i++) {
            borrow.reindex();
            supply.reindex();
            skip(MONTH);
            (uint256 borrow_indexi, uint256 borrow_dti) = borrow.index();
            (uint256 supply_indexi, uint256 supply_dti) = supply.index();
            assertGt(borrow_indexi, 1.0e18);
            assertGt(supply_indexi, 1.0e18);
            assertEq(borrow_dti, MONTH);
            assertEq(supply_dti, MONTH);
        }
        (uint256 borrow_index, uint256 borrow_dt) = borrow.index();
        (uint256 supply_index, uint256 supply_dt) = borrow.index();
        assertEq(borrow_index, 1.105170_918075_647603e18);
        assertEq(supply_index, 1.105170_918075_647603e18);
        assertEq(borrow_dt, MONTH);
        assertEq(supply_dt, MONTH);
        ///
        assertEq(supply.balanceOf(self), 1.000000_000000_000000e18);
        assertEq(borrow.balanceOf(self), 0.900000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.105170_918075_647603e18);
        assertEq(borrow.totalOf(self), 0.994653_826268_082842e18);
        ///
        borrow.burn(self, 0, false);
        ///
        assertEq(borrow.balanceOf(self), 0.994653_826268_082842e18);
        assertEq(borrow.totalOf(self), 0.994653_826268_082842e18);
        assertEq(supply.balanceOf(self), 1.000000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.186479_322816_130603e18); //!
        ///
        supply.burn(self, 0, false);
        ///
        assertEq(supply.balanceOf(self), 1.186479_322816_130603e18); //!
        assertEq(borrow.balanceOf(self), 0.994653_826268_082842e18);
        assertEq(supply.totalOf(self), 1.186479_322816_130603e18); //!
        assertEq(borrow.totalOf(self), 0.994653_826268_082842e18);
    }
}
