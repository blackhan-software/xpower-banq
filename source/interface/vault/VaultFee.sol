// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {VaultFee} from "../../struct/VaultFee.sol";

interface IFeeVaultRW {}

interface IFeeVaultRO {
    /**
     * Gets the fee structure of the vault.
     * @return fee structure of the vault
     */
    function fee() external view returns (VaultFee memory);
}

interface IFeeVault is IFeeVaultRW, IFeeVaultRO, IERC4626 {}
