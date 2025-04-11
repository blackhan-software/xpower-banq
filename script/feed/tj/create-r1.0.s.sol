// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {Feed_R1} from "../../../source/contract/feed/traderjoe/Feed-v1.0.sol";
import {IFeed} from "../../../source/interface/Feed.sol";
import {console} from "forge-std/console.sol";
import {BaseScript} from "../../base.s.sol";

contract ReverseFeed is Feed_R1 {
    constructor(address source) Feed_R1(source) {}
}

contract Run is BaseScript {
    function run(address source) external {
        vm.startBroadcast();
        IFeed feed = new ReverseFeed(source);
        vm.stopBroadcast();
        console.log("FEED_ADDRESS", address(feed));
    }
}
