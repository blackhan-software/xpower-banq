// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {IOracle} from "../source/interface/Oracle.sol";
import {String} from "../source/library/String.sol";
import {Token} from "../source/library/Token.sol";

import {RateLimit} from "../source/struct/RateLimit.sol";
import {IRModel} from "../source/struct/IRModel.sol";
import {VaultFee} from "../source/struct/VaultFee.sol";
import {Weight} from "../source/struct/Weight.sol";
import {Script} from "forge-std/Script.sol";

abstract contract BaseScript is Script {
    function addressOf(
        string memory prefix,
        uint256 n
    ) internal view returns (address) {
        string memory name = String.join(prefix, n, "_ADDRESS");
        address value = vm.envAddress(name);
        assert(value != address(0));
        return value;
    }

    function addressOf(string memory prefix) internal view returns (address) {
        string memory name = String.join(prefix, "_ADDRESS");
        address value = vm.envAddress(name);
        assert(value != address(0));
        return value;
    }

    function addressOf(
        string memory prefix,
        string memory suffix
    ) internal view returns (address) {
        string memory name = String.join(prefix, "_ADDRESS_", suffix);
        address value = vm.envAddress(name);
        assert(value != address(0));
        return value;
    }

    function vaultFeeOf(
        string memory symbol
    ) internal view returns (VaultFee memory) {
        string memory name = String.join(symbol, "_STOPAGE");
        string memory data = vm.envString(name);
        bytes memory json = vm.parseJson(data);
        return abi.decode(json, (VaultFee));
    }

    function irmOf(
        string memory symbol
    ) internal view returns (IRModel memory) {
        string memory name = String.join(symbol, "_IRMODEL");
        string memory data = vm.envString(name);
        bytes memory json = vm.parseJson(data);
        return abi.decode(json, (IRModel));
    }

    function weightOf(
        string memory symbol
    ) internal view returns (Weight memory) {
        string memory name = String.join(symbol, "_WEIGHTS");
        string memory data = vm.envString(name);
        bytes memory json = vm.parseJson(data);
        return abi.decode(json, (Weight));
    }

    function rateLimitOf(
        string memory symbol
    ) internal view returns (RateLimit memory) {
        string memory name = String.join(symbol, "_RATELIM");
        string memory data = vm.envString(name);
        bytes memory json = vm.parseJson(data);
        return abi.decode(json, (RateLimit));
    }

    function tokenOf(
        string memory symbol
    ) internal view returns (IERC20Metadata) {
        IERC20Metadata token = IERC20Metadata(addressOf(symbol));
        assert(address(token) != address(0));
        return token;
    }

    function decimalsOf(IERC20 asset) internal view returns (uint8) {
        return Token.decimalsOf(asset);
    }

    function symbolOf(IERC20 asset) internal view returns (string memory) {
        return Token.symbolOf(asset);
    }

    function zeropad(
        string memory prefix,
        uint256 number,
        uint256 length
    ) internal pure returns (string memory) {
        string memory text = Strings.toString(number);
        uint256 text_length = bytes(text).length;
        if (text_length < length) {
            uint256 padding_length = length - text_length;
            bytes memory padding = new bytes(padding_length);
            for (uint256 i = 0; i < padding_length; ++i) {
                padding[i] = "0";
            }
            return string(abi.encodePacked(prefix, padding, text));
        }
        return string(abi.encodePacked(prefix, text));
    }
}
