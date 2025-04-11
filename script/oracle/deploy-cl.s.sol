// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {Oracle_000, Oracle_001, Oracle_002} from "../../source/contract/oracle/chainlink/Oracles.sol";
import {OracleInit} from "../../script/oracle/enroll.s.sol";
import {IOracle} from "../../source/interface/Oracle.sol";
import {IAcma} from "../../source/interface/Acma.sol";

import {String} from "../../source/library/String.sol";
import {console} from "forge-std/console.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    using OracleInit for IOracle;

    function run(uint256 index, bool use_feeds) external {
        IAcma acma = IAcma(addressOf("ACMA"));
        vm.startBroadcast();
        IOracle oracle = OracleFactory(index, use_feeds, acma);
        vm.stopBroadcast();
        vm.startBroadcast();
        acma.grantRole(acma.ACMA_RELATE_ROLE(), msg.sender, 0);
        oracle.enroll(acma);
        acma.revokeRole(acma.ACMA_RELATE_ROLE(), msg.sender);
        vm.stopBroadcast();
        console_log(index, oracle);
    }

    function OracleFactory(
        uint256 index,
        bool use_feeds,
        IAcma acma
    ) internal returns (IOracle) {
        if (index == 0) {
            return new Oracle_000(use_feeds, acma);
        }
        if (index == 1) {
            return new Oracle_001(use_feeds, acma);
        }
        if (index == 2) {
            return new Oracle_002(use_feeds, acma);
        }
        revert(String.join("invalid index: ", index));
    }

    function console_log(uint256 index, IOracle oracle) internal pure {
        string memory env_name = String.join(
            zeropad("L", index, 3),
            "_ADDRESS"
        );
        console.log(env_name, address(oracle));
    }
}
