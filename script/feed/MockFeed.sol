// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IFeed} from "../../source/interface/Feed.sol";

/**
 * @title MockFeed contract to provide predefined (bid, ask) quotes
 */
contract MockFeed is IFeed {
    constructor(uint256 bid, IERC20 source, uint256 ask, IERC20 target) {
        _bid_token = source;
        _ask_token = target;
        _bid = bid;
        _ask = ask;
    }

    function getQuotes(uint amount) external view returns (uint bid, uint ask) {
        return (amount * _bid, amount * _ask);
    }

    function getBidToken() external view returns (address bidToken) {
        return address(_bid_token);
    }

    function getAskToken() external view returns (address askToken) {
        return address(_ask_token);
    }

    IERC20 private immutable _bid_token;
    IERC20 private immutable _ask_token;
    uint256 private immutable _bid;
    uint256 private immutable _ask;
}
