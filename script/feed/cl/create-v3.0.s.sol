// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {Feed_V3} from "../../../source/contract/feed/chainlink/Feed-v3.0.sol";
import {IFeed} from "../../../source/interface/Feed.sol";
import {console} from "forge-std/console.sol";
import {BaseScript} from "../../base.s.sol";

contract ForwardFeed is Feed_V3 {
    address private _bid_token;
    address private _ask_token;

    constructor(
        address source,
        address bid_token,
        address ask_token
    ) Feed_V3(source) {
        _bid_token = bid_token;
        _ask_token = ask_token;
    }

    function getBidToken() external view override returns (address) {
        return _bid_token;
    }

    function getAskToken() external view override returns (address) {
        return _ask_token;
    }
}

contract Run is BaseScript {
    function run(
        address source,
        address bid_token,
        address ask_token
    ) external {
        vm.startBroadcast();
        IFeed feed = new ForwardFeed(source, bid_token, ask_token);
        vm.stopBroadcast();
        console.log("FEED_ADDRESS", address(feed));
    }
}
