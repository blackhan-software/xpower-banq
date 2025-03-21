// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

/**
 * @title Quote of (bid, ask) prices
 */
struct Quote {
    /** bid price of quote */
    uint256 bid;
    /** ask price of quote */
    uint256 ask;
    /** timestamp of quote */
    uint256 time;
}
