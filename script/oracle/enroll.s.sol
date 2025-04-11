// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IOracle} from "../../source/interface/Oracle.sol";
import {IAcma} from "../../source/interface/Acma.sol";
import {OracleInit} from "../library/OracleInit.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    using OracleInit for IOracle;

    function run(string memory name) external {
        IAcma acma = IAcma(addressOf("ACMA"));
        IOracle oracle = IOracle(addressOf(name));
        vm.startBroadcast();
        acma.grantRole(acma.ACMA_RELATE_ROLE(), msg.sender, 0);
        oracle.enroll(acma);
        acma.revokeRole(acma.ACMA_RELATE_ROLE(), msg.sender);
        vm.stopBroadcast();
    }
}
