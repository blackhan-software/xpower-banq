// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IFeeVault} from "../../interface/vault/VaultFee.sol";
import {VaultFee} from "../../struct/VaultFee.sol";
import {Constant} from "../../library/Constant.sol";
import {String} from "../../library/String.sol";

/**
 * @title Vault with entry and exit fees (in basis points)
 */
abstract contract FeeVault is IFeeVault, ERC4626 {
    using SafeERC20 for IERC20Metadata;

    uint256 private constant BPS_SCALE = 1e4 * Constant.BPS;
    address private immutable _entry_recipient;
    address private immutable _exit_recipient;

    constructor(
        IERC20Metadata token_,
        VaultFee memory fee_
    )
        ERC4626(token_)
        ERC20(
            String.join(token_.name(), " Vault"),
            String.join("v", token_.symbol())
        )
    {
        if (fee_.entryRecipient != address(0)) {
            _entry_recipient = fee_.entryRecipient;
        } else {
            _entry_recipient = address(this);
        }
        if (fee_.exitRecipient != address(0)) {
            _exit_recipient = fee_.exitRecipient;
        } else {
            _exit_recipient = address(this);
        }
    }

    function _decimalsOffset() internal view virtual override returns (uint8) {
        return 9; // improved precision
    }

    // ////////////////////////////////////////////////////////////////
    // IERC4626 overrides
    // ////////////////////////////////////////////////////////////////

    /// @dev Preview taking an entry fee on deposit. See {IERC4626-previewDeposit}.
    function previewDeposit(
        uint256 assets
    ) public view virtual override(IERC4626, ERC4626) returns (uint256) {
        uint256 bps = _feeOnTotal(assets, _entryFee());
        return super.previewDeposit(assets - bps);
    }

    /// @dev Preview adding an entry fee on mint. See {IERC4626-previewMint}.
    function previewMint(
        uint256 shares
    ) public view virtual override(IERC4626, ERC4626) returns (uint256) {
        uint256 assets = super.previewMint(shares);
        return assets + _feeOnRaw(assets, _entryFee());
    }

    /// @dev Preview adding an exit fee on withdraw. See {IERC4626-previewWithdraw}.
    function previewWithdraw(
        uint256 assets
    ) public view virtual override(IERC4626, ERC4626) returns (uint256) {
        uint256 bps = _feeOnRaw(assets, _exitFee());
        return super.previewWithdraw(assets + bps);
    }

    /// @dev Preview taking an exit fee on redeem. See {IERC4626-previewRedeem}.
    function previewRedeem(
        uint256 shares
    ) public view virtual override(IERC4626, ERC4626) returns (uint256) {
        uint256 assets = super.previewRedeem(shares);
        return assets - _feeOnTotal(assets, _exitFee());
    }

    /// @dev Send entry fee to {_entryFeeRecipient}. See {IERC4626-_deposit}.
    function _deposit(
        address caller,
        address receiver,
        uint256 assets,
        uint256 shares
    ) internal virtual override {
        uint256 bps = _feeOnTotal(assets, _entryFee());
        address recipient = _entryFeeRecipient();
        super._deposit(caller, receiver, assets, shares);
        if (bps > 0 && recipient != address(this)) {
            IERC20Metadata(asset()).safeTransfer(recipient, bps);
        }
    }

    /// @dev Send exit fee to {_exitFeeRecipient}. See {IERC4626-_deposit}.
    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal virtual override {
        uint256 bps = _feeOnRaw(assets, _exitFee());
        address recipient = _exitFeeRecipient();
        super._withdraw(caller, receiver, owner, assets, shares);
        if (bps > 0 && recipient != address(this)) {
            IERC20Metadata(asset()).safeTransfer(recipient, bps);
        }
    }

    // ////////////////////////////////////////////////////////////////
    // Fee configuration
    // ////////////////////////////////////////////////////////////////

    function _entryFeeRecipient() internal view virtual returns (address) {
        return _entry_recipient;
    }

    function _entryFee() internal view virtual returns (uint256);

    function _exitFeeRecipient() internal view virtual returns (address) {
        return _exit_recipient;
    }

    function _exitFee() internal view virtual returns (uint256);

    // ////////////////////////////////////////////////////////////////
    // Fee operations
    // ////////////////////////////////////////////////////////////////

    /// @dev Fee ought to be added to `assets` that doesn't include fees.
    /// Used in {IERC4626-mint} and {IERC4626-withdraw} operations.
    function _feeOnRaw(
        uint256 assets,
        uint256 bps
    ) private pure returns (uint256) {
        return Math.mulDiv(assets, bps, BPS_SCALE, Math.Rounding.Ceil);
    }

    /// @dev Fee part of `assets` that already does include fees.
    /// Used in {IERC4626-deposit} and {IERC4626-redeem} operations.
    function _feeOnTotal(
        uint256 assets,
        uint256 bps
    ) private pure returns (uint256) {
        return Math.mulDiv(assets, bps, bps + BPS_SCALE, Math.Rounding.Ceil);
    }

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}
