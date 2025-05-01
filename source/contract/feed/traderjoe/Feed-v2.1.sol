// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IPair_V2} from "../../../interface/feed/traderjoe/Pair-v2.1.sol";
import {IFeed} from "../../../interface/Feed.sol";

/**
 * @title TraderJoe-v2.1 price feed
 */
abstract contract Feed_V2 is IFeed {
    IPair_V2 internal immutable _pair;

    constructor(address source) {
        _pair = IPair_V2(source);
    }

    // ////////////////////////////////////////////////////////////////
    // IFeed
    // ////////////////////////////////////////////////////////////////

    function getBidToken() public view virtual override returns (address) {
        return _pair.getTokenX();
    }

    function getAskToken() public view virtual override returns (address) {
        return _pair.getTokenY();
    }

    function getQuotes(
        uint256 amount
    ) public view virtual returns (uint256, uint256) {
        uint128 value = _valueOf(amount);
        uint256 bid = _bidOf(value, true);
        uint256 ask = _askOf(value, false);
        return (bid, ask);
    }

    function _valueOf(uint256 amount) internal pure returns (uint128) {
        require(amount <= type(uint128).max, ArithmeticOverflow(amount));
        return uint128(amount);
    }

    function _bidOf(uint128 amount, bool flag) internal view returns (uint128) {
        // slither-disable-next-line unused-return
        (uint128 left, uint128 bid, ) = _pair.getSwapOut(amount, flag);
        if (left > 0) {
            revert InsufficientLiquidity(amount);
        }
        return bid;
    }

    function _askOf(uint128 amount, bool flag) internal view returns (uint128) {
        // slither-disable-next-line unused-return
        (uint128 ask, uint128 left, ) = _pair.getSwapIn(amount, flag);
        if (left > 0) {
            revert InsufficientLiquidity(amount);
        }
        return ask;
    }

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}

/**
 * @title TraderJoe-v2.1 price feed: *reversed* pair!
 */
abstract contract Feed_R2 is Feed_V2 {
    constructor(address source) Feed_V2(source) {}

    // ////////////////////////////////////////////////////////////////
    // IFeed
    // ////////////////////////////////////////////////////////////////

    function getBidToken() public view override returns (address) {
        return super.getAskToken();
    }

    function getAskToken() public view override returns (address) {
        return super.getBidToken();
    }

    function getQuotes(
        uint256 amount
    ) public view override returns (uint256 bid, uint256 ask) {
        uint128 value = _valueOf(amount);
        bid = _bidOf(value, false);
        ask = _askOf(value, true);
    }

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}
