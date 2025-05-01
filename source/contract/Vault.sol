// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IAccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {ISupplyPosition} from "../interface/Position.sol";
import {IBorrowPosition} from "../interface/Position.sol";
import {IVault} from "../interface/Vault.sol";

import {VaultFee} from "../struct/VaultFee.sol";
import {UtilVault} from "./vault/VaultUtil.sol";
import {FeeVault} from "./vault/VaultFee.sol";

import {VaultSupervised} from "./supervised/Vault.sol";
import {Constant} from "../library/Constant.sol";

/**
 * @title Pool's vault contract to safe-guard collateral
 */
contract Vault is IVault, VaultSupervised, FeeVault, UtilVault, Ownable {
    constructor(
        address owner_,
        IERC20Metadata token_,
        VaultFee memory fee_,
        ISupplyPosition supply_,
        IBorrowPosition borrow_,
        IAccessManager acma_
    )
        Ownable(owner_)
        VaultSupervised(acma_)
        FeeVault(token_, fee_)
        UtilVault(supply_, borrow_)
    {
        _setTarget(FEE_ENTRY_ID, fee_.entry, FOR_3M);
        _setTarget(FEE_EXIT_ID, fee_.exit, FOR_3M);
    }

    // ////////////////////////////////////////////////////////////////
    // FeeVault
    // ////////////////////////////////////////////////////////////////

    function fee() external view override returns (VaultFee memory) {
        return
            VaultFee({
                entryRecipient: _entryFeeRecipient(),
                exitRecipient: _exitFeeRecipient(),
                entry: _entryFee(),
                exit: _exitFee()
            });
    }

    function _entryFee() internal view override returns (uint256) {
        return parameterOf(FEE_ENTRY_ID);
    }

    function _exitFee() internal view override returns (uint256) {
        return parameterOf(FEE_EXIT_ID);
    }

    // ////////////////////////////////////////////////////////////////
    // ERC4626
    // ////////////////////////////////////////////////////////////////

    function deposit(
        uint256 assets,
        address receiver
    ) public override(ERC4626, IERC4626) onlyOwner returns (uint256 shares) {
        return super.deposit(assets, receiver);
    }

    function mint(
        uint256 shares,
        address receiver
    ) public override(ERC4626, IERC4626) onlyOwner returns (uint256 assets) {
        return super.mint(shares, receiver);
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public override(ERC4626, IERC4626) onlyOwner returns (uint256 shares) {
        return super.withdraw(assets, receiver, owner);
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public override(ERC4626, IERC4626) onlyOwner returns (uint256 assets) {
        return super.redeem(shares, receiver, owner);
    }

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}
