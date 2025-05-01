// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IUtilVault} from "./vault/VaultUtil.sol";
import {IFeeVault} from "./vault/VaultFee.sol";

interface IVault is IFeeVault, IUtilVault {}
