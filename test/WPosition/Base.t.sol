// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {WPosition} from "../../source/contract/WPosition.sol";
import {VaultFee} from "../../source/struct/VaultFee.sol";
import {IRModel} from "../../source/struct/IRModel.sol";

import {BaseTest as Test} from "../Position/Base.t.sol";

contract BaseTest is Test {
    constructor(VaultFee memory fee_, IRModel memory irm_) Test(fee_, irm_) {
        wsupply = new WPosition(supply);
        wborrow = new WPosition(borrow);
    }

    WPosition internal wsupply;
    WPosition internal wborrow;
}
