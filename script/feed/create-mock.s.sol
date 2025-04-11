// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {String} from "../../source/library/String.sol";
import {IFeed} from "../../source/interface/Feed.sol";
import {console} from "forge-std/console.sol";
import {BaseScript} from "../base.s.sol";
import {MockFeed} from "./MockFeed.sol";

contract Run is BaseScript {
    function run(
        uint256 bid,
        string memory source_symbol,
        uint256 ask,
        string memory target_symbol
    ) external {
        IERC20 source = IERC20(addressOf(source_symbol));
        IERC20 target = IERC20(addressOf(target_symbol));
        vm.startBroadcast();
        IFeed feed = new MockFeed(bid, source, ask, target);
        vm.stopBroadcast();
        console_log(source_symbol, target_symbol, feed);
    }

    function console_log(
        string memory source_symbol,
        string memory target_symbol,
        IFeed feed
    ) internal pure {
        string memory pair = String.join(source_symbol, "/", target_symbol);
        console.log(pair, "FEED_ADDRESS", address(feed));
    }
}
