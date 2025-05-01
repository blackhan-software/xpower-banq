// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {IAcma} from "../../../interface/Acma.sol";
import {IFeed} from "../../../interface/Feed.sol";
import {FeedLib} from "../../../library/Feed.sol";
import {Oracle} from "../../Oracle.sol";

import {AVAX_USD, USD_AVAX} from "../../feed/chainlink/Feeds-v3.0.sol";
import {USDC_USD, USD_USDC} from "../../feed/chainlink/Feeds-v3.0.sol";
import {USDT_USD, USD_USDT} from "../../feed/chainlink/Feeds-v3.0.sol";

/**
 * @title TWAP Oracle contract to provide (bid, ask) quotes
 */
contract Oracle_000 is Oracle {
    using FeedLib for IFeed;

    function name() external pure override returns (string memory) {
        return "CL/Oracle Primus";
    }

    constructor(
        bool use_feeds,
        IAcma acma
    ) Oracle(DECAY_01HL, 1 hours, 14 days, acma) {
        if (!use_feeds) {
            return; // skip *hard-coded* feeds!
        }
        IFeed avax_usd = new AVAX_USD();
        _enlist(avax_usd.bidToken(), avax_usd.askToken(), avax_usd, FOR_1Y);
        IFeed usd_avax = new USD_AVAX();
        _enlist(usd_avax.bidToken(), usd_avax.askToken(), usd_avax, FOR_1Y);
    }
}

contract Oracle_001 is Oracle {
    using FeedLib for IFeed;

    function name() external pure override returns (string memory) {
        return "CL/Oracle Secundus";
    }

    constructor(
        bool use_feeds,
        IAcma acma
    ) Oracle(DECAY_01HL, 1 hours, 14 days, acma) {
        if (!use_feeds) {
            return; // skip *hard-coded* feeds!
        }
        IFeed usdc_usd = new USDC_USD();
        _enlist(usdc_usd.bidToken(), usdc_usd.askToken(), usdc_usd, FOR_1Y);
        IFeed usd_usdc = new USD_USDC();
        _enlist(usd_usdc.bidToken(), usd_usdc.askToken(), usd_usdc, FOR_1Y);
    }
}

contract Oracle_002 is Oracle {
    using FeedLib for IFeed;

    function name() external pure override returns (string memory) {
        return "CL/Oracle Tertius";
    }

    constructor(
        bool use_feeds,
        IAcma acma
    ) Oracle(DECAY_01HL, 1 hours, 14 days, acma) {
        if (!use_feeds) {
            return; // skip *hard-coded* feeds!
        }
        IFeed usdt_usd = new USDT_USD();
        _enlist(usdt_usd.bidToken(), usdt_usd.askToken(), usdt_usd, FOR_1Y);
        IFeed usd_usdt = new USD_USDT();
        _enlist(usd_usdt.bidToken(), usd_usdt.askToken(), usd_usdt, FOR_1Y);
    }
}
