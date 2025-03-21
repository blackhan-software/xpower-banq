// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Test} from "forge-std/Test.sol";

import {IAggregator_V3} from "../../../source/interface/feed/chainlink/Aggregator-v3.0.sol";
import {Feed_V3} from "../../../source/contract/feed/chainlink/Feed-v3.0.sol";
import {Feed_R3} from "../../../source/contract/feed/chainlink/Feed-v3.0.sol";

contract MockFeed_V3 is Feed_V3 {
    constructor(
        int256 answer,
        uint8 digits
    ) Feed_V3(address(new MockAggregator(answer, digits))) {}

    function getBidToken() external pure override returns (address) {
        return address(0); // ABC
    }

    function getAskToken() external pure override returns (address) {
        return address(1); // XYZ
    }
}

contract MockFeed_R3 is Feed_R3 {
    constructor(
        int256 answer,
        uint8 digits
    ) Feed_R3(address(new MockAggregator(answer, digits))) {}

    function getBidToken() external pure override returns (address) {
        return address(1); // XYZ
    }

    function getAskToken() external pure override returns (address) {
        return address(0); // ABC
    }
}

contract MockAggregator is IAggregator_V3 {
    uint8 private immutable _decimals;
    int256 private immutable _answer;

    constructor(int256 answer, uint8 digits) {
        _decimals = digits;
        _answer = answer;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function description() external pure override returns (string memory) {
        return "MockAggregator";
    }

    function getRoundData(
        uint80
    )
        external
        view
        override
        returns (uint80, int256, uint256, uint256, uint80)
    {
        return this.latestRoundData();
    }

    function latestRoundData()
        external
        view
        override
        returns (uint80, int256, uint256, uint256, uint80)
    {
        return (0, _answer, block.timestamp, block.timestamp, 0);
    }

    function version() external pure override returns (uint256) {
        return 3;
    }
}
