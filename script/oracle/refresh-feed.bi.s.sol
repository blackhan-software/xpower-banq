// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IOracle} from "../../source/interface/Oracle.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    function run(
        string memory oracle_name,
        string memory source_symbol,
        string memory target_symbol
    ) external {
        IOracle oracle = IOracle(addressOf(oracle_name));
        IERC20 source = tokenOf(source_symbol);
        IERC20 target = tokenOf(target_symbol);
        vm.startBroadcast();
        oracle.refresh(source, target);
        oracle.refresh(target, source);
        vm.stopBroadcast();
    }
}
