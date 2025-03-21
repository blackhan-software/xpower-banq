// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IPair_V1} from "../../../interface/feed/traderjoe/Pair-v1.0.sol";
import {IFeed} from "../../../interface/Feed.sol";

/**
 * @title TraderJoe-v1.0 price feed
 */
abstract contract Feed_V1 is IFeed {
    IPair_V1 internal immutable _pair;

    constructor(address source) {
        _pair = IPair_V1(source);
    }

    // ////////////////////////////////////////////////////////////////
    // IFeed
    // ////////////////////////////////////////////////////////////////

    function getBidToken() public view virtual override returns (address) {
        return _pair.token0();
    }

    function getAskToken() public view virtual override returns (address) {
        return _pair.token1();
    }

    function getQuotes(
        uint256 amount
    ) public view virtual returns (uint256, uint256) {
        // slither-disable-next-line unused-return
        (uint112 lhs, uint112 rhs, ) = _pair.getReserves();
        (uint256 bid, uint256 ask) = _quotesOf(amount, lhs, rhs);
        return (bid, ask);
    }

    function _quotesOf(
        uint256 amount,
        uint256 lhs,
        uint256 rhs
    ) internal pure returns (uint256, uint256) {
        require(lhs <= type(uint256).max - amount, ArithmeticOverflow(amount));
        uint256 bid = Math.mulDiv(amount, rhs, uint256(lhs) + amount);
        require(lhs > amount, InsufficientLiquidity(amount));
        uint256 ask = Math.mulDiv(amount, rhs, uint256(lhs) - amount);
        return (bid, ask);
    }

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}

/**
 * @title TraderJoe-v1.0 price feed: *reversed* pair!
 */
abstract contract Feed_R1 is Feed_V1 {
    constructor(address source) Feed_V1(source) {}

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
        // slither-disable-next-line unused-return
        (uint112 rhs, uint112 lhs, ) = _pair.getReserves();
        (bid, ask) = _quotesOf(amount, lhs, rhs);
    }

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}
