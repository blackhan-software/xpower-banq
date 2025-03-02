// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {Constant} from "../../source/library/Constant.sol";
import {IRModel} from "../../source/struct/IRModel.sol";
import {Test} from "forge-std/Test.sol";

contract RateTest is Test {
    uint256 constant MONTH = Constant.MONTH;
    uint256 constant ONE = Constant.ONE;
    uint256 constant PCT = Constant.PCT;
    uint256 constant BPS = Constant.BPS;
    IRModel internal irm;

    constructor(IRModel memory irm_) {
        irm = irm_;
    }

    function test_units() public pure {
        assertEq(ONE, BPS * 1e4);
        assertEq(PCT, BPS * 1e2);
    }
}
