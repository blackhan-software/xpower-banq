// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {Feed_V1} from "./Feed-v1.0.sol";
import {Feed_R1} from "./Feed-v1.0.sol";

/// @dev https://lfj.gg/avalanche/pool/v1/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/0x40243Cf10759571Ac787092844660D9d6D82234B
contract APOW_XPOW is Feed_V1 {
    constructor() Feed_V1(0x80ca5B97B49b33cb1Fa7F3c69385A8F43A2c55Ef) {}
}

/// @dev https://lfj.gg/avalanche/pool/v1/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/0x40243Cf10759571Ac787092844660D9d6D82234B
contract XPOW_APOW is Feed_R1 {
    constructor() Feed_R1(0x80ca5B97B49b33cb1Fa7F3c69385A8F43A2c55Ef) {}
}

/// @dev https://lfj.gg/avalanche/pool/v1/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/AVAX
contract APOW_AVAX is Feed_V1 {
    constructor() Feed_V1(0x17671c032c90BcDFE0F0d0C80dDAcDD939ab150c) {}
}

/// @dev https://lfj.gg/avalanche/pool/v1/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/AVAX
contract AVAX_APOW is Feed_R1 {
    constructor() Feed_R1(0x17671c032c90BcDFE0F0d0C80dDAcDD939ab150c) {}
}

/// @dev https://lfj.gg/avalanche/pool/v1/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E
contract APOW_USDC is Feed_V1 {
    constructor() Feed_V1(0xDd31806E8299F4560085e54FD99780Ee5b448A10) {}
}

/// @dev https://lfj.gg/avalanche/pool/v1/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E
contract USDC_APOW is Feed_R1 {
    constructor() Feed_R1(0xDd31806E8299F4560085e54FD99780Ee5b448A10) {}
}

/// @dev https://lfj.gg/avalanche/pool/v1/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7
contract APOW_USDT is Feed_V1 {
    constructor() Feed_V1(0xA07563165a5EF2BCeF52FE9061d303449510A366) {}
}

/// @dev https://lfj.gg/avalanche/pool/v1/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7
contract USDT_APOW is Feed_R1 {
    constructor() Feed_R1(0xA07563165a5EF2BCeF52FE9061d303449510A366) {}
}
