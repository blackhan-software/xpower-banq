// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IAccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {Parameterized} from "../governance/Parameterized.sol";
import {Constant} from "../../library/Constant.sol";

/**
 * @title Contract to manage position access control
 */
abstract contract PositionSupervised is Parameterized {
    constructor(IAccessManager acma_) Parameterized(acma_) {}

    // ////////////////////////////////////////////////////////////////
    // IParameterized
    // ////////////////////////////////////////////////////////////////

    function _setTarget(
        uint256 id,
        uint256 value,
        uint256 timestamp
    ) internal override {
        if (id == UTIL_ID || id == RATE_ID) {
            require(
                value <= Constant.ONE - 1, // epsilon
                TooLarge({id: id, value: value, max: Constant.ONE - 1})
            );
        } else if (id == SPREAD_ID) {
            require(
                value <= Constant.HLF,
                TooLarge({id: id, value: value, max: Constant.HLF})
            );
        } else {
            revert Unknown(id); // including CAP_ID!
        }
        super._setTarget(id, value, timestamp);
    }

    /** ID of cap limitation of position: [0..2^224]. */
    uint256 public constant CAP_ID = 0x1;
    /** ID of utilization rate percent: [0..100%). */
    uint256 public constant UTIL_ID = 0x2;
    /** ID of interest rate percent: [0..100%). */
    uint256 public constant RATE_ID = 0x4;
    /** ID of half-spread percent: [0..50%]. */
    uint256 public constant SPREAD_ID = 0x8;

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}
