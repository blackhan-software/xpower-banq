// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC4626, ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {IWPosition} from "../interface/WPosition.sol";
import {IPosition} from "../interface/Position.sol";
import {String} from "../library/String.sol";

contract WPosition is IWPosition, ERC4626 {
    constructor(
        IPosition token_
    )
        ERC4626(token_)
        ERC20(
            String.join("Wrapped", " ", token_.name()),
            String.join("w", token_.symbol())
        )
    {}

    // ////////////////////////////////////////////////////////////////
    // IERC4626
    // ////////////////////////////////////////////////////////////////

    function totalAssets()
        public
        view
        override(IERC4626, ERC4626)
        returns (uint256)
    {
        return IPosition(asset()).totalOf(address(this));
    }

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}
