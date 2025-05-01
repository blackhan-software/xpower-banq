// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IAggregator_V3} from "../../../interface/feed/chainlink/Aggregator-v3.0.sol";
import {IFeed} from "../../../interface/Feed.sol";

/**
 * @title Chainlink-v3.0 data feed
 */
abstract contract Feed_V3 is IFeed {
    IAggregator_V3 internal immutable _feed;
    uint256 internal immutable _unit;

    constructor(address source) {
        _feed = IAggregator_V3(source);
        _unit = 10 ** _feed.decimals();
    }

    // ////////////////////////////////////////////////////////////////
    // IFeed
    // ////////////////////////////////////////////////////////////////

    function getQuotes(
        uint256 amount
    ) public view virtual returns (uint256, uint256) {
        // slither-disable-next-line unused-return
        (, int256 answer, , , ) = _feed.latestRoundData();
        if (answer >= 0) {
            uint256 quote = Math.mulDiv(amount, uint256(answer), _unit);
            return (quote, quote);
        }
        revert NegativeQuote(answer);
    }

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}

/**
 * @title Chainlink-v3.0 data feed: *inverted* values!
 */
abstract contract Feed_R3 is Feed_V3 {
    constructor(address source) Feed_V3(source) {}

    // ////////////////////////////////////////////////////////////////
    // IFeed
    // ////////////////////////////////////////////////////////////////

    function getQuotes(
        uint256 amount
    ) public view override returns (uint256 bid, uint256 ask) {
        // slither-disable-next-line unused-return
        (, int256 answer, , , ) = _feed.latestRoundData();
        if (answer >= 0) {
            uint256 quote = Math.mulDiv(amount, _unit, uint256(answer));
            return (quote, quote); // no spread: bid = ask
        }
        revert NegativeQuote(answer);
    }

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}
