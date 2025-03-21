// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {SupplyPosition} from "../../source/contract/Position.sol";
import {BorrowPosition} from "../../source/contract/Position.sol";
import {IRModel} from "../../source/struct/IRModel.sol";
import {VaultFee} from "../../source/struct/VaultFee.sol";
import {BaseTest} from "./Base.t.sol";

contract Scenario_001Test is BaseTest {
    constructor() BaseTest(VAULT_NIL, IR_MODEL) {}

    function setUp() public {
        supply.cap(2.0e18 ** 2, 0);
        borrow.cap(1.8e18 ** 2, 0);
        supply.mint(self, 2.0e18, false);
        borrow.mint(self, 1.8e18, false);
    }

    /**
     * Scenario: 2.0E18 supply, 1.8E18 borrow, 12 months
     */
    function test_S1E18_B9E17_12Ma_1() public {
        supply.transfer(papa, 1.0e18);
        skip(12 * MONTH);
        ///
        assertEq(supply.balanceOf(self), 1.000000_000000_000000e18);
        assertEq(borrow.balanceOf(self), 1.800000_000000_000000e18);
        assertEq(supply.balanceOf(papa), 1.000000_000000_000000e18);
        assertEq(borrow.balanceOf(papa), 0.000000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.105170_918075_647624e18);
        assertEq(borrow.totalOf(self), 1.989307_652536_165723e18); //!
        assertEq(supply.totalOf(papa), 1.105170_918075_647624e18);
        assertEq(borrow.totalOf(papa), 0.000000_000000_000000e18);
        ///
        vm.prank(papa); // with interest accrual!
        assertTrue(supply.transfer(self, 1.0e18));
        ///
        assertEq(supply.balanceOf(self), 2.105170_918075_647624e18);
        assertEq(borrow.balanceOf(self), 1.800000_000000_000000e18);
        assertEq(supply.balanceOf(papa), 0.105170_918075_647624e18);
        assertEq(borrow.balanceOf(papa), 0.000000_000000_000000e18);
        assertEq(supply.totalOf(self), 2.105170_918075_647624e18);
        assertEq(borrow.totalOf(self), 1.970466_677260_290205e18); //!
        assertEq(supply.totalOf(papa), 0.105170_918075_647624e18);
        assertEq(borrow.totalOf(papa), 0.000000_000000_000000e18);
    }

    function test_S1E18_B9E17_12Ma_2() public {
        supply.transfer(papa, 0.5e18);
        skip(12 * MONTH);
        supply.transfer(papa, 0.5e18);
        ///
        assertEq(supply.balanceOf(self), 1.157756_377113_471436e18);
        assertEq(borrow.balanceOf(self), 1.800000_000000_000000e18);
        assertEq(supply.balanceOf(papa), 1.052585_459037_823812e18);
        assertEq(borrow.balanceOf(papa), 0.000000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.157756_377113_471436e18);
        assertEq(borrow.totalOf(self), 1.970466_677260_290205e18);
        assertEq(supply.totalOf(papa), 1.052585_459037_823812e18);
        assertEq(borrow.totalOf(papa), 0.000000_000000_000000e18);
        ///
        vm.prank(papa); // with interest accrual!
        assertTrue(supply.transfer(self, 1.0e18));
        ///
        assertEq(supply.balanceOf(self), 2.157756_377113_471436e18);
        assertEq(borrow.balanceOf(self), 1.800000_000000_000000e18);
        assertEq(supply.balanceOf(papa), 0.052585_459037_823812e18);
        assertEq(borrow.balanceOf(papa), 0.000000_000000_000000e18);
        assertEq(supply.totalOf(self), 2.157756_377113_471436e18);
        assertEq(borrow.totalOf(self), 1.970466_677260_290205e18);
        assertEq(supply.totalOf(papa), 0.052585_459037_823812e18);
        assertEq(borrow.totalOf(papa), 0.000000_000000_000000e18);
    }

    function test_S1E18_B9E17_12Ma_3() public {
        skip(12 * MONTH);
        supply.transfer(papa, 1.0e18);
        ///
        assertEq(supply.balanceOf(self), 1.210341_836151_295248e18);
        assertEq(borrow.balanceOf(self), 1.800000_000000_000000e18);
        assertEq(supply.balanceOf(papa), 1.000000_000000_000000e18);
        assertEq(borrow.balanceOf(papa), 0.000000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.210341_836151_295248e18);
        assertEq(borrow.totalOf(self), 1.970466_677260_290205e18);
        assertEq(supply.totalOf(papa), 1.000000_000000_000000e18);
        assertEq(borrow.totalOf(papa), 0.000000_000000_000000e18);
        ///
        vm.prank(papa); // with interest accrual!
        assertTrue(supply.transfer(self, 1.0e18));
        ///
        assertEq(supply.balanceOf(self), 2.210341_836151_295248e18);
        assertEq(borrow.balanceOf(self), 1.800000_000000_000000e18);
        assertEq(supply.balanceOf(papa), 0.000000_000000_000000e18);
        assertEq(borrow.balanceOf(papa), 0.000000_000000_000000e18);
        assertEq(supply.totalOf(self), 2.210341_836151_295248e18);
        assertEq(borrow.totalOf(self), 1.970466_677260_290205e18);
        assertEq(supply.totalOf(papa), 0.000000_000000_000000e18);
        assertEq(borrow.totalOf(papa), 0.000000_000000_000000e18);
    }

    /**
     * Scenario: 2.0E18 supply, 1.8E18 borrow, 12 months
     */
    function test_S1E18_B9E17_12Mb_1() public {
        supply.transfer(papa, 1.0e18);
        skip(12 * MONTH);
        ///
        assertEq(supply.balanceOf(self), 1.000000_000000_000000e18);
        assertEq(borrow.balanceOf(self), 1.800000_000000_000000e18);
        assertEq(supply.balanceOf(papa), 1.000000_000000_000000e18);
        assertEq(borrow.balanceOf(papa), 0.000000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.105170_918075_647624e18);
        assertEq(borrow.totalOf(self), 1.989307_652536_165723e18); //!
        assertEq(supply.totalOf(papa), 1.105170_918075_647624e18);
        assertEq(borrow.totalOf(papa), 0.000000_000000_000000e18);
        ///
        vm.prank(papa);
        supply.approve(papa, 1.0e18); // with interest accrual!
        vm.prank(papa);
        assertTrue(supply.transferFrom(papa, self, 1.0e18));
        ///
        assertEq(supply.balanceOf(self), 2.105170_918075_647624e18);
        assertEq(borrow.balanceOf(self), 1.800000_000000_000000e18);
        assertEq(supply.balanceOf(papa), 0.105170_918075_647624e18);
        assertEq(borrow.balanceOf(papa), 0.000000_000000_000000e18);
        assertEq(supply.totalOf(self), 2.105170_918075_647624e18);
        assertEq(borrow.totalOf(self), 1.970466_677260_290205e18); //!
        assertEq(supply.totalOf(papa), 0.105170_918075_647624e18);
        assertEq(borrow.totalOf(papa), 0.000000_000000_000000e18);
    }

    function test_S1E18_B9E17_12Mb_2() public {
        supply.transfer(papa, 0.5e18);
        skip(12 * MONTH);
        supply.transfer(papa, 0.5e18);
        ///
        assertEq(supply.balanceOf(self), 1.157756_377113_471436e18);
        assertEq(borrow.balanceOf(self), 1.800000_000000_000000e18);
        assertEq(supply.balanceOf(papa), 1.052585_459037_823812e18);
        assertEq(borrow.balanceOf(papa), 0.000000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.157756_377113_471436e18);
        assertEq(borrow.totalOf(self), 1.970466_677260_290205e18);
        assertEq(supply.totalOf(papa), 1.052585_459037_823812e18);
        assertEq(borrow.totalOf(papa), 0.000000_000000_000000e18);
        ///
        vm.prank(papa);
        supply.approve(papa, 1.0e18); // with interest accrual!
        vm.prank(papa);
        assertTrue(supply.transferFrom(papa, self, 1.0e18));
        ///
        assertEq(supply.balanceOf(self), 2.157756_377113_471436e18);
        assertEq(borrow.balanceOf(self), 1.800000_000000_000000e18);
        assertEq(supply.balanceOf(papa), 0.052585_459037_823812e18);
        assertEq(borrow.balanceOf(papa), 0.000000_000000_000000e18);
        assertEq(supply.totalOf(self), 2.157756_377113_471436e18);
        assertEq(borrow.totalOf(self), 1.970466_677260_290205e18);
        assertEq(supply.totalOf(papa), 0.052585_459037_823812e18);
        assertEq(borrow.totalOf(papa), 0.000000_000000_000000e18);
    }

    function test_S1E18_B9E17_12Mb_3() public {
        skip(12 * MONTH);
        supply.transfer(papa, 1.0e18);
        ///
        assertEq(supply.balanceOf(self), 1.210341_836151_295248e18);
        assertEq(borrow.balanceOf(self), 1.800000_000000_000000e18);
        assertEq(supply.balanceOf(papa), 1.000000_000000_000000e18);
        assertEq(borrow.balanceOf(papa), 0.000000_000000_000000e18);
        assertEq(supply.totalOf(self), 1.210341_836151_295248e18);
        assertEq(borrow.totalOf(self), 1.970466_677260_290205e18);
        assertEq(supply.totalOf(papa), 1.000000_000000_000000e18);
        assertEq(borrow.totalOf(papa), 0.000000_000000_000000e18);
        ///
        vm.prank(papa);
        supply.approve(papa, 1.0e18); // with interest accrual!
        vm.prank(papa);
        assertTrue(supply.transferFrom(papa, self, 1.0e18));
        ///
        assertEq(supply.balanceOf(self), 2.210341_836151_295248e18);
        assertEq(borrow.balanceOf(self), 1.800000_000000_000000e18);
        assertEq(supply.balanceOf(papa), 0.000000_000000_000000e18);
        assertEq(borrow.balanceOf(papa), 0.000000_000000_000000e18);
        assertEq(supply.totalOf(self), 2.210341_836151_295248e18);
        assertEq(borrow.totalOf(self), 1.970466_677260_290205e18);
        assertEq(supply.totalOf(papa), 0.000000_000000_000000e18);
        assertEq(borrow.totalOf(papa), 0.000000_000000_000000e18);
    }
}
