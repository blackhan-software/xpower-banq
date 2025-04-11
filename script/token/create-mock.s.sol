// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {console} from "forge-std/console.sol";
import {MockToken} from "./MockToken.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    function run(uint256 supply, string memory symbol) external {
        vm.startBroadcast();
        MockToken xyz = new MockToken(supply, symbol);
        vm.stopBroadcast();
        console_log(xyz);
    }

    function console_log(MockToken token) internal view {
        console.log(token.totalSupply(), token.symbol(), address(token));
    }
}
