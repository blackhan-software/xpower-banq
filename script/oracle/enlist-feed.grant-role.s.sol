// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IAcma} from "../../source/interface/Acma.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    function run(address account) external {
        IAcma am = IAcma(addressOf("ACMA"));
        vm.startBroadcast();
        am.grantRole(am.FEED_ENLIST_ADMIN_ROLE(), msg.sender, 0);
        am.grantRole(am.FEED_ENLIST_ROLE(), account, 0);
        vm.stopBroadcast();
    }
}
