// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {console} from "forge-std/console.sol";

import {IPool} from "../../source/interface/Pool.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    function run(uint256 pool_index, address victim) external {
        IPool pool = IPool(addressOf(zeropad("P", pool_index, 3)));
        IERC20Metadata[] memory tokens = pool.tokens();
        vm.startBroadcast();
        for (uint256 i = 0; i < tokens.length; i++) {
            tokens[i].approve(address(pool), type(uint256).max);
        }
        pool.liquidate(victim, 0);
        vm.stopBroadcast();
        for (uint256 i = 0; i < tokens.length; i++) {
            console_log(pool.supplyOf(tokens[i]), victim);
            console_log(pool.borrowOf(tokens[i]), victim);
        }
    }

    function console_log(IERC20 token, address victim) internal view {
        console.log(symbolOf(token), token.balanceOf(victim));
    }
}
