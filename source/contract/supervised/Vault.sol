// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IAccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {Parameterized} from "../governance/Parameterized.sol";
import {Constant} from "../../library/Constant.sol";

/**
 * @title Contract to manage vault access control
 */
abstract contract VaultSupervised is Parameterized {
    constructor(IAccessManager acma_) Parameterized(acma_) {}

    // ////////////////////////////////////////////////////////////////
    // IParameterized
    // ////////////////////////////////////////////////////////////////

    function _setTarget(
        uint256 id,
        uint256 value,
        uint256 timestamp
    ) internal override {
        if (id == FEE_ENTRY_ID || id == FEE_EXIT_ID) {
            require(
                value <= Constant.HLF,
                TooLarge({id: id, value: value, max: Constant.HLF})
            );
        } else {
            revert Unknown(id);
        }
        super._setTarget(id, value, timestamp);
    }

    /** ID of entry fee percent: [0..50%]. */
    uint256 public constant FEE_ENTRY_ID = 0x1;
    /** ID of exit fee percent: [0..50%]. */
    uint256 public constant FEE_EXIT_ID = 0x2;

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}
