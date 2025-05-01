// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IFeed} from "./Feed.sol";

interface ISupervisedOracleRW {
    /**
     * Enlists the price feed into the oracle.
     *
     * @param source token of the feed
     * @param target token of the feed
     * @param feed to enlist
     * @param duration enlist with (seconds)
     */
    function enlist(
        IERC20 source,
        IERC20 target,
        IFeed feed,
        uint256 duration
    ) external;
}

interface ISupervisedOracleRO {
    /**
     * Checks whether a price feed is enlisted.
     *
     * @param source token of the feed
     * @param target token of the feed
     * @return flag whether the feed is enlisted
     */
    function enlisted(
        IERC20 source,
        IERC20 target
    ) external view returns (bool flag);
}

interface ISupervisedOracle is ISupervisedOracleRW, ISupervisedOracleRO {}

interface IOracleRW {
    /**
     * Fetches the latest quotes from the price feed and
     * updates the oracle (if latter has the retwap-role).
     *
     * @param source token of the feed
     * @param target token of the feed
     */
    function refresh(IERC20 source, IERC20 target) external;

    /**
     * Fetches the latest quotes from the price feed and
     * updates the oracle (if caller has the retwap-role).
     *
     * @param source token of the feed
     * @param target token of the feed
     */
    function retwap(IERC20 source, IERC20 target) external;
}

interface IOracleRO {
    /**
     * Gets the name of the oracle.
     * @return name of the oracle
     */
    function name() external view returns (string memory);

    /**
     * Get the feed enlisted in the oracle.
     *
     * @param source token of the feed
     * @param target token of the feed
     *
     * @return feed address enlisted
     * @return duration enlisted with (seconds)
     */
    function getFeed(
        IERC20 source,
        IERC20 target
    ) external view returns (IFeed feed, uint256 duration);

    /**
     * Gets the latest (bid, ask) quotes from the price feed.
     *
     * @param amount the amount to quote for
     * @param source token of the feed
     * @param target token of the feed
     * @return bid price of the quote
     * @return ask price of the quote
     */
    function getQuotes(
        uint256 amount,
        IERC20 source,
        IERC20 target
    ) external view returns (uint256 bid, uint256 ask);

    /**
     * Gets the latest mid quote from the price feed.
     *
     * @param amount the amount to quote for
     * @param source token of the feed
     * @param target token of the feed
     * @return mid price of the quote
     */
    function getQuote(
        uint256 amount,
        IERC20 source,
        IERC20 target
    ) external view returns (uint256 mid);

    /**
     * Checks whether the price feed has been refreshed recently.
     *
     * @param source token of the feed
     * @param target token of the feed
     * @return flag whether the price feed has been refreshed recently
     */
    function refreshed(
        IERC20 source,
        IERC20 target
    ) external view returns (bool flag);

    /**
     * Gets the refresh difficulty.
     *
     * @return difficulty of refresh
     */
    function refreshDifficulty() external view returns (uint256);
}

interface IOracle is ISupervisedOracle, IOracleRW, IOracleRO {
    /** Thrown on feed too early. */
    error TooEarlyFeed(IERC20 source, IERC20 target, IFeed feed, uint256 dt);
    /** Thrown on feed too retro. */
    error TooRetroFeed(IERC20 source, IERC20 target, IFeed feed, uint256 dt);
    /** Thrown on missing quote. */
    error MissingQuote(IERC20 source, IERC20 target);
    /** Thrown on missing feed. */
    error MissingFeed(IERC20 source, IERC20 target);
    /** Thrown on invalid pair. */
    error InvalidPair(IERC20 source, IERC20 target);
}
