// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

interface IFeed {
    /**
     * Gets the (bid, ask) quotes for the amount.
     *
     * @param amount to quote for
     * @return bid price of the quote
     * @return ask price of the quote
     */
    function getQuotes(
        uint256 amount
    ) external view returns (uint256 bid, uint256 ask);

    /**
     * @return bidToken of the feed
     */
    function getBidToken() external view returns (address bidToken);

    /**
     * @return askToken of the feed
     */
    function getAskToken() external view returns (address askToken);

    /** Thrown on insufficient liquidity. */
    error InsufficientLiquidity(uint256 amount);
    /** Thrown on arithmetic overflow. */
    error ArithmeticOverflow(uint256 amount);
    /** Thrown on negative quote. */
    error NegativeQuote(int256 answer);
    /** Thrown on zero address. */
    error ZeroAddress();
}
