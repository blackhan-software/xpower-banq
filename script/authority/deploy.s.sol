// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IAcma} from "../../source/interface/Acma.sol";
import {Acma} from "../../source/contract/Acma.sol";
import {console} from "forge-std/console.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    function run() external {
        vm.startBroadcast();
        IAcma acma = new Acma(addressOf("BOSS"));
        vm.stopBroadcast();
        console_log(acma);
    }

    function console_log(IAcma acma) internal pure {
        console.log("ACMA_ADDRESS", address(acma));
    }
}
