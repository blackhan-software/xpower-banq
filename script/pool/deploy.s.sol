// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

import {IOracle} from "../../source/interface/Oracle.sol";
import {IAcma} from "../../source/interface/Acma.sol";
import {IPool} from "../../source/interface/Pool.sol";
import {Pool} from "../../source/contract/Pool.sol";

import {String} from "../../source/library/String.sol";
import {console} from "forge-std/console.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    function run(
        uint256 pool_index,
        string memory name,
        string[] memory symbols
    ) external {
        IAcma acma = IAcma(addressOf("ACMA"));
        IOracle oracle = IOracle(addressOf(name));
        IERC20Metadata[] memory assets = new IERC20Metadata[](symbols.length);
        for (uint256 i = 0; i < symbols.length; i++) {
            assets[i] = tokenOf(symbols[i]);
        }
        vm.startBroadcast();
        IPool pool = new Pool(assets, oracle, acma);
        vm.stopBroadcast();
        console_log(pool_index, pool);
    }

    function console_log(uint256 index, IPool pool) internal pure {
        string memory env_name = String.join(
            zeropad("P", index, 3),
            "_ADDRESS"
        );
        console.log(env_name, address(pool));
    }
}
