// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {console} from "forge-std/console.sol";

import {IPool} from "../../source/interface/Pool.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    function run(
        uint256 pool_index,
        string memory symbol,
        uint256 amount
    ) external {
        IPool pool = IPool(addressOf(zeropad("P", pool_index, 3)));
        IERC20 token = tokenOf(symbol);
        vm.startBroadcast();
        pool.redeem(token, amount);
        vm.stopBroadcast();
        console_log(tx.origin, pool.supplyOf(token));
    }

    function console_log(address account, IERC20 supply) internal view {
        console.log(account, supply.balanceOf(account), symbolOf(supply));
    }
}
