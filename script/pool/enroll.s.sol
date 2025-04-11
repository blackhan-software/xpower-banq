// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {String} from "../../source/library/String.sol";
import {IAcma} from "../../source/interface/Acma.sol";
import {IPool} from "../../source/interface/Pool.sol";
import {PoolInit} from "../library/PoolInit.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    using PoolInit for IPool;

    function run(uint256 pool_index) external {
        IAcma acma = IAcma(addressOf("ACMA"));
        IPool pool = IPool(addressOf(zeropad("P", pool_index, 3)));
        vm.startBroadcast();
        acma.grantRole(acma.ACMA_RELATE_ADMIN_ROLE(), msg.sender, 0);
        acma.grantRole(acma.ACMA_RELATE_ROLE(), msg.sender, 0);
        pool.enroll(acma);
        acma.revokeRole(acma.ACMA_RELATE_ROLE(), msg.sender);
        acma.revokeRole(acma.ACMA_RELATE_ADMIN_ROLE(), msg.sender);
        vm.stopBroadcast();
    }
}
