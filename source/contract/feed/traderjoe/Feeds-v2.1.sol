// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {Feed_V2} from "./Feed-v2.1.sol";
import {Feed_R2} from "./Feed-v2.1.sol";

/// @dev https://lfj.gg/avalanche/pool/v22/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/AVAX/100
contract APOW_AVAX is Feed_V2 {
    constructor() Feed_V2(0xE42E6efFfC7287045cd3a0D282C430DAF9fABD5b) {}
}

/// @dev https://lfj.gg/avalanche/pool/v22/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/AVAX/100
contract AVAX_APOW is Feed_R2 {
    constructor() Feed_R2(0xE42E6efFfC7287045cd3a0D282C430DAF9fABD5b) {}
}

/// @dev https://lfj.gg/avalanche/pool/v22/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E/100
contract APOW_USDC is Feed_V2 {
    constructor() Feed_V2(0x5e3bB6Dc9C9A7E5235d26605445C28Dafc8a5Eb1) {}
}

/// @dev https://lfj.gg/avalanche/pool/v22/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E/100
contract USDC_APOW is Feed_R2 {
    constructor() Feed_R2(0x5e3bB6Dc9C9A7E5235d26605445C28Dafc8a5Eb1) {}
}

/// @dev https://lfj.gg/avalanche/pool/v22/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7/100
contract APOW_USDT is Feed_V2 {
    constructor() Feed_V2(0x513924b3A9773aC74543aE70bb154efBFf02AA9c) {}
}

/// @dev https://lfj.gg/avalanche/pool/v22/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7/100
contract USDT_APOW is Feed_R2 {
    constructor() Feed_R2(0x513924b3A9773aC74543aE70bb154efBFf02AA9c) {}
}

/// @dev https://lfj.gg/avalanche/pool/v22/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/0x152b9d0FdC40C096757F570A51E494bd4b943E50/100
contract APOW_BTCB is Feed_V2 {
    constructor() Feed_V2(0xE9F2284b3Fe34bD17D2411b0859eD7c188D4b32c) {}
}

/// @dev https://lfj.gg/avalanche/pool/v22/0xa3810387B4e3955B368964E4f792B8Ce02E8515b/0x152b9d0FdC40C096757F570A51E494bd4b943E50/100
contract BTCB_APOW is Feed_R2 {
    constructor() Feed_R2(0xE9F2284b3Fe34bD17D2411b0859eD7c188D4b32c) {}
}
