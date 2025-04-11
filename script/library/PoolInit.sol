// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {Selector} from "../../source/library/Selector.sol";
import {String} from "../../source/library/String.sol";

import {IAcma} from "../../source/interface/Acma.sol";
import {IPool} from "../../source/interface/Pool.sol";

library PoolInit {
    function enroll(IPool pool, IAcma acma) internal {
        acma.relate(
            address(pool),
            Selector.SET_TARGET,
            acma.POOL_SET_TARGET_ROLE()
        );
        acma.relate(
            address(pool),
            Selector.CAP_SUPPLY,
            acma.POOL_CAP_SUPPLY_ROLE()
        );
        acma.relate(
            address(pool),
            Selector.CAP_BORROW,
            acma.POOL_CAP_BORROW_ROLE()
        );
        acma.relate(
            address(pool),
            Selector.TMP_SUPPLY,
            acma.POOL_TMP_SUPPLY_ROLE()
        );
        acma.relate(
            address(pool),
            Selector.TMP_BORROW,
            acma.POOL_TMP_BORROW_ROLE()
        );
        acma.relate(
            address(pool),
            pool.enlist.selector,
            acma.POOL_ENLIST_ROLE()
        );
        acma.relate(
            address(pool),
            pool.enwrap.selector,
            acma.POOL_ENWRAP_ROLE()
        );
        acma.relate(
            address(pool),
            pool.square.selector,
            acma.POOL_SQUARE_ROLE()
        );
    }
}
