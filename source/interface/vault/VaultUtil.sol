// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {ISupplyPosition} from "../../interface/Position.sol";
import {IBorrowPosition} from "../../interface/Position.sol";
import {VaultUtil} from "../../struct/VaultUtil.sol";

interface IUtilVaultRO {
    /**
     * Gets the current utilization of the vault.
     * @return util current of the vault
     */
    function util() external view returns (uint256);
}

interface IUtilVault is IUtilVaultRO {
    /** @return address of supply-position */
    function supply() external view returns (ISupplyPosition);

    /** @return address of borrow-position */
    function borrow() external view returns (IBorrowPosition);
}
