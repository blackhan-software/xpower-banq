// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {console} from "forge-std/console.sol";

import {String} from "../../source/library/String.sol";
import {IPool} from "../../source/interface/Pool.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    function run(
        uint256 pool_index,
        string memory symbol,
        uint256 amount
    ) external {
        IPool pool = IPool(addressOf(zeropad("P", pool_index, 3)));
        IERC20Metadata token = tokenOf(symbol);
        vm.startBroadcast();
        pool.capSupply(token, amount);
        vm.stopBroadcast();
        (uint256 cap, uint256 duration) = pool.capSupply(token);
        assert(cap == amount && duration == 0);
        console_log(symbol, token, amount);
    }

    function console_log(
        string memory symbol,
        IERC20Metadata token,
        uint256 amount
    ) internal pure {
        console.log(String.join(symbol, "_ADDRESS"), address(token), amount);
    }
}
