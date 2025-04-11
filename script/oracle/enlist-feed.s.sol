// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IOracle} from "../../source/interface/Oracle.sol";
import {IFeed} from "../../source/interface/Feed.sol";

import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    function run(
        string memory oracle_name,
        string memory source_symbol,
        string memory target_symbol,
        address feed_address
    ) external {
        IOracle oracle = IOracle(addressOf(oracle_name));
        IERC20 source = tokenOf(source_symbol);
        IERC20 target = tokenOf(target_symbol);
        IFeed feed = IFeed(feed_address);
        vm.startBroadcast();
        oracle.enlist(source, target, feed, 0);
        vm.stopBroadcast();
    }
}
