// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IAcma} from "../../source/interface/Acma.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    function run(address account) external {
        IAcma am = IAcma(addressOf("ACMA"));
        vm.startBroadcast();
        am.revokeRole(am.FEED_RETWAP_ROLE(), account);
        am.revokeRole(am.FEED_RETWAP_ADMIN_ROLE(), msg.sender);
        vm.stopBroadcast();
    }
}
