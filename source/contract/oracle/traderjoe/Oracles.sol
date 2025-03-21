// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {IAcma} from "../../../interface/Acma.sol";
import {IFeed} from "../../../interface/Feed.sol";
import {FeedLib} from "../../../library/Feed.sol";
import {Oracle} from "../../Oracle.sol";

import {APOW_XPOW, XPOW_APOW} from "../../feed/traderjoe/Feeds-v1.0.sol";
import {APOW_AVAX, AVAX_APOW} from "../../feed/traderjoe/Feeds-v1.0.sol";
import {APOW_USDC, USDC_APOW} from "../../feed/traderjoe/Feeds-v1.0.sol";
import {APOW_USDT, USDT_APOW} from "../../feed/traderjoe/Feeds-v1.0.sol";

/**
 * @title TWAP Oracle contract to provide (bid, ask) quotes
 */
contract Oracle_000 is Oracle {
    using FeedLib for IFeed;

    function name() external pure override returns (string memory) {
        return "TJ/Oracle Primus";
    }

    constructor(
        bool with_feeds,
        IAcma acma
    ) Oracle(DECAY_01HL, 1 hours, 14 days, acma) {
        if (!with_feeds) {
            return; // skip *hard-coded* feeds!
        }
        IFeed apow_xpow = new APOW_XPOW();
        _enlist(apow_xpow.bidToken(), apow_xpow.askToken(), apow_xpow, FOR_1Y);
        IFeed xpow_apow = new XPOW_APOW();
        _enlist(xpow_apow.bidToken(), xpow_apow.askToken(), xpow_apow, FOR_1Y);
    }
}

contract Oracle_001 is Oracle {
    using FeedLib for IFeed;

    function name() external pure override returns (string memory) {
        return "TJ/Oracle Secundus";
    }

    constructor(
        bool with_feeds,
        IAcma acma
    ) Oracle(DECAY_01HL, 1 hours, 14 days, acma) {
        if (!with_feeds) {
            return; // skip *hard-coded* feeds!
        }
        IFeed apow_avax = new APOW_AVAX();
        _enlist(apow_avax.bidToken(), apow_avax.askToken(), apow_avax, FOR_1Y);
        IFeed avax_apow = new AVAX_APOW();
        _enlist(avax_apow.bidToken(), avax_apow.askToken(), avax_apow, FOR_1Y);
    }
}

contract Oracle_002 is Oracle {
    using FeedLib for IFeed;

    function name() external pure override returns (string memory) {
        return "TJ/Oracle Tertius";
    }

    constructor(
        bool with_feeds,
        IAcma acma
    ) Oracle(DECAY_01HL, 1 hours, 14 days, acma) {
        if (!with_feeds) {
            return; // skip *hard-coded* feeds!
        }
        IFeed apow_usdc = new APOW_USDC();
        _enlist(apow_usdc.bidToken(), apow_usdc.askToken(), apow_usdc, FOR_1Y);
        IFeed usdc_apow = new USDC_APOW();
        _enlist(usdc_apow.bidToken(), usdc_apow.askToken(), usdc_apow, FOR_1Y);
    }
}

contract Oracle_003 is Oracle {
    using FeedLib for IFeed;

    function name() external pure override returns (string memory) {
        return "TJ/Oracle Quartus";
    }

    constructor(
        bool with_feeds,
        IAcma acma
    ) Oracle(DECAY_01HL, 1 hours, 14 days, acma) {
        if (!with_feeds) {
            return; // skip *hard-coded* feeds!
        }
        IFeed apow_usdt = new APOW_USDT();
        _enlist(apow_usdt.bidToken(), apow_usdt.askToken(), apow_usdt, FOR_1Y);
        IFeed usdt_apow = new USDT_APOW();
        _enlist(usdt_apow.bidToken(), usdt_apow.askToken(), usdt_apow, FOR_1Y);
    }
}
