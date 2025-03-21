// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IAccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {OracleSupervised} from "../../source/contract/supervised/Oracle.sol";
import {IFeed} from "../../source/interface/Feed.sol";
import {IOracle} from "../../source/interface/Oracle.sol";
import {Token} from "../../source/library/Token.sol";
import {Quote} from "../../source/struct/Quote.sol";

interface IMockOracle is IOracle {
    function setQuote(
        Quote memory quote,
        IERC20 source,
        IERC20 target
    ) external;
}

contract RWMockOracle is IMockOracle, OracleSupervised {
    function name() external pure override returns (string memory) {
        return "RW/MockOracle";
    }

    constructor() OracleSupervised(IAccessManager(address(0))) {}

    // ////////////////////////////////////////////////////////////////
    // ISupervisedOracleRW
    // ////////////////////////////////////////////////////////////////

    function enlist(IERC20, IERC20, IFeed, uint256) external pure override {
        revert("RW/MockOracle: not available");
    }

    // ////////////////////////////////////////////////////////////////
    // ISupervisedOracleRO
    // ////////////////////////////////////////////////////////////////

    function enlisted(IERC20, IERC20) external pure override returns (bool) {
        revert("RW/MockOracle: not available");
    }

    // ////////////////////////////////////////////////////////////////
    // IOracleRW
    // ////////////////////////////////////////////////////////////////

    function refreshed(IERC20, IERC20) external pure override returns (bool) {
        revert("RW/MockOracle: not available");
    }

    function refreshDifficulty() external pure override returns (uint256) {
        revert("RW/MockOracle: not available");
    }

    function refresh(IERC20, IERC20) external pure override {
        revert("RW/MockOracle: not available");
    }

    function retwap(IERC20, IERC20) external pure override {
        revert("RW/MockOracle: not available");
    }

    // ////////////////////////////////////////////////////////////////
    // IOracleRO & IMockOracle
    // ////////////////////////////////////////////////////////////////

    function getFeed(
        IERC20,
        IERC20
    ) external pure override returns (IFeed, uint256) {
        revert("RW/MockOracle: not available");
    }

    function getQuotes(
        uint256 amount,
        IERC20 source,
        IERC20 target
    ) external view override returns (uint256 bid, uint256 ask) {
        uint256 quote = getQuote(amount, source, target);
        return (quote, quote); // no spread: bid = ask
    }

    function getQuote(
        uint256 amount,
        IERC20 source,
        IERC20 target
    ) public view override returns (uint256) {
        Quote memory quote = _quotes[source][target];
        amount *= Token.unitOf(target);
        amount /= Token.unitOf(source);
        if (quote.time > 0) {
            amount *= quote.ask;
            amount /= quote.bid;
        }
        return amount;
    }

    function setQuote(
        Quote memory quote,
        IERC20 source,
        IERC20 target
    ) external {
        _quotes[source][target] = quote;
    }

    mapping(IERC20 => mapping(IERC20 => Quote)) _quotes;
}
