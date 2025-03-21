// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IUtilVault} from "../../interface/vault/VaultUtil.sol";
import {ISupplyPosition} from "../../interface/Position.sol";
import {IBorrowPosition} from "../../interface/Position.sol";

import {VaultUtil} from "../../struct/VaultUtil.sol";
import {Constant} from "../../library/Constant.sol";

/**
 * @title Vault contract for utilization rates
 */
abstract contract UtilVault is IUtilVault {
    ISupplyPosition public immutable supply;
    IBorrowPosition public immutable borrow;
    VaultUtil[] private _utils;

    constructor(ISupplyPosition supply_, IBorrowPosition borrow_) {
        supply = supply_;
        borrow = borrow_;
    }

    // ////////////////////////////////////////////////////////////////
    // IUtilVault
    // ////////////////////////////////////////////////////////////////

    function util() external view override returns (uint256) {
        return _util(supply.totalSupply(), borrow.totalSupply());
    }

    function _util(
        uint256 supplied,
        uint256 borrowed
    ) private pure returns (uint256 ratio) {
        if (supplied > 0) {
            ratio = Math.mulDiv(Constant.ONE, borrowed, supplied);
            ratio = Math.min(Constant.ONE, ratio); // cap at 100%
        } else {
            ratio = 0;
        }
    }

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}
