// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {Feed_V3} from "./Feed-v3.0.sol";
import {Feed_R3} from "./Feed-v3.0.sol";

/// @dev https://data.chain.link/feeds/avalanche/mainnet/avax-usd
contract AVAX_USD is Feed_V3 {
    constructor() Feed_V3(0x0A77230d17318075983913bC2145DB16C7366156) {}

    function getBidToken() external pure override returns (address) {
        return 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7; // AVAX
    }

    function getAskToken() external pure override returns (address) {
        return address(1); // pseudo-USD
    }
}

/// @dev https://data.chain.link/feeds/avalanche/mainnet/avax-usd
contract USD_AVAX is Feed_R3 {
    constructor() Feed_R3(0x0A77230d17318075983913bC2145DB16C7366156) {}

    function getBidToken() external pure override returns (address) {
        return address(1); // pseudo-USD
    }

    function getAskToken() external pure override returns (address) {
        return 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7; // AVAX
    }
}

/// @dev https://data.chain.link/feeds/avalanche/mainnet/usdc-usd
contract USDC_USD is Feed_V3 {
    constructor() Feed_V3(0xF096872672F44d6EBA71458D74fe67F9a77a23B9) {}

    function getBidToken() external pure override returns (address) {
        return 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E; // USDC
    }

    function getAskToken() external pure override returns (address) {
        return address(1); // pseudo-USD
    }
}

/// @dev https://data.chain.link/feeds/avalanche/mainnet/usdc-usd
contract USD_USDC is Feed_R3 {
    constructor() Feed_R3(0xF096872672F44d6EBA71458D74fe67F9a77a23B9) {}

    function getBidToken() external pure override returns (address) {
        return address(1); // pseudo-USD
    }

    function getAskToken() external pure override returns (address) {
        return 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E; // USDC
    }
}

/// @dev https://data.chain.link/feeds/avalanche/mainnet/usdt-usd
contract USDT_USD is Feed_V3 {
    constructor() Feed_V3(0xEBE676ee90Fe1112671f19b6B7459bC678B67e8a) {}

    function getBidToken() external pure override returns (address) {
        return 0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7; // USDT
    }

    function getAskToken() external pure override returns (address) {
        return address(1); // pseudo-USD
    }
}

/// @dev https://data.chain.link/feeds/avalanche/mainnet/usdt-usd
contract USD_USDT is Feed_R3 {
    constructor() Feed_R3(0xEBE676ee90Fe1112671f19b6B7459bC678B67e8a) {}

    function getBidToken() external pure override returns (address) {
        return address(1); // pseudo-USD
    }

    function getAskToken() external pure override returns (address) {
        return 0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7; // USDT
    }
}
