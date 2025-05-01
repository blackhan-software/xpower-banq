// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IAccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Parameterized} from "../governance/Parameterized.sol";
import {Constant} from "../../library/Constant.sol";

/**
 * @title Contract to manage oracle access control
 */
abstract contract OracleSupervised is Parameterized {
    constructor(IAccessManager acma_) Parameterized(acma_) {}

    // ////////////////////////////////////////////////////////////////
    // IParameterized
    // ////////////////////////////////////////////////////////////////

    function _setTarget(
        uint256 id,
        uint256 value,
        uint256 timestamp
    ) internal override {
        if (id == DECAY_ID) {
            require(
                value <= Constant.ONE,
                TooLarge({id: id, value: value, max: Constant.ONE})
            );
            require(
                value >= Constant.HLF,
                TooSmall({id: id, value: value, min: Constant.HLF})
            );
        } else if (id == DELAY_ID) {
            require(
                value <= Constant.MONTH * 3,
                TooLarge({id: id, value: value, max: Constant.MONTH * 3})
            );
            require(
                value >= Constant.WEEK,
                TooSmall({id: id, value: value, min: Constant.WEEK})
            );
        } else if (id == LEVEL_ID) {
            require(
                value <= Constant.POW,
                TooLarge({id: id, value: value, max: Constant.POW})
            );
        } else if (id == LIMIT_ID) {
            require(
                value <= Constant.DAY,
                TooLarge({id: id, value: value, max: Constant.DAY})
            );
            require(
                value >= Constant.SEC,
                TooSmall({id: id, value: value, min: Constant.SEC})
            );
        } else {
            revert Unknown(id);
        }
        super._setTarget(id, value, timestamp);
    }

    /** ID of EWMA decay parameter: [0.5..1.0]. */
    uint256 public constant DECAY_ID = 0x1;
    /** ID of delay of feed-enlist: [1w..3m]. */
    uint256 public constant DELAY_ID = 0x2;
    /** ID of PoW difficulty level: [0..64]. */
    uint256 public constant LEVEL_ID = 0x4;
    /** ID of TWAP rate-limit: [1s..1d]. */
    uint256 public constant LIMIT_ID = 0x8;

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}
