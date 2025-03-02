// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

library Token {
    /**
     * Gets the unit of the asset.
     *
     * @param asset to query for
     * @return unit of asset
     */
    function unitOf(IERC20 asset) internal view returns (uint256) {
        return unitOf(address(asset));
    }

    /**
     * Gets the unit of the asset.
     *
     * @param asset to query for
     * @return unit of asset
     */
    function unitOf(address asset) internal view returns (uint256) {
        return 10 ** decimalsOf(asset);
    }

    /**
     * Gets the decimals of the asset.
     *
     * @param asset to query for
     * @return decimals of asset
     */
    function decimalsOf(IERC20 asset) internal view returns (uint8) {
        return decimalsOf(address(asset));
    }

    /**
     * Gets the decimals of the asset.
     *
     * @param asset to query for
     * @return decimals of asset
     */
    function decimalsOf(address asset) internal view returns (uint8) {
        (bool ok, bytes memory encoded) = asset.staticcall(
            abi.encodeCall(IERC20Metadata.decimals, ())
        );
        if (ok && encoded.length >= 32) {
            uint256 decimals = abi.decode(encoded, (uint256));
            if (decimals <= type(uint8).max) {
                return uint8(decimals);
            }
        }
        revert InvalidDecimals(asset);
    }

    /** Thrown on invalid decimals. */
    error InvalidDecimals(address asset);

    /**
     * Gets the symbol of the asset.
     *
     * @param asset to query for
     * @return symbol of asset
     */
    function symbolOf(IERC20 asset) internal view returns (string memory) {
        return symbolOf(address(asset));
    }

    /**
     * Gets the symbol of the asset.
     *
     * @param asset to query for
     * @return symbol of asset
     */
    function symbolOf(address asset) internal view returns (string memory) {
        (bool ok, bytes memory encoded) = asset.staticcall(
            abi.encodeCall(IERC20Metadata.symbol, ())
        );
        if (ok && encoded.length >= 32) {
            return abi.decode(encoded, (string));
        }
        revert InvalidSymbol();
    }

    /**
     * Thrown on invalid symbol.
     */
    error InvalidSymbol();
}
