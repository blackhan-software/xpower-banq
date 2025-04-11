// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {Selector} from "../../source/library/Selector.sol";
import {String} from "../../source/library/String.sol";

import {IOracle} from "../../source/interface/Oracle.sol";
import {IAcma} from "../../source/interface/Acma.sol";

library OracleInit {
    function enroll(IOracle oracle, IAcma acma) internal {
        acma.relate(
            address(oracle),
            Selector.SET_TARGET,
            acma.FEED_SET_TARGET_ROLE()
        );
        acma.relate(
            address(oracle),
            oracle.enlist.selector,
            acma.FEED_ENLIST_ROLE()
        );
        acma.relate(
            address(oracle),
            oracle.retwap.selector,
            acma.FEED_RETWAP_ROLE()
        );
    }
}
