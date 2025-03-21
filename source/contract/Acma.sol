// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {AccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {Supervised} from "./supervised/Supervised.sol";
import {IAcma} from "../interface/Acma.sol";
import {Roles} from "../library/Roles.sol";

contract Acma is IAcma, Supervised, AccessManager {
    constructor(address admin_) Supervised(this) AccessManager(admin_) {
        _setTargetFunctionRole(
            address(this),
            IAcma.relate.selector,
            ACMA_RELATE_ROLE
        );
    }

    // ////////////////////////////////////////////////////////////////
    // IAcma
    // ////////////////////////////////////////////////////////////////

    function relate(
        address target,
        bytes4 selector,
        uint64 role_id
    ) external override restricted {
        _setTargetFunctionRole(target, selector, role_id);
    }

    // ////////////////////////////////////////////////////////////////
    // Roles
    // ////////////////////////////////////////////////////////////////

    uint64 public immutable SUPPLY_SET_TARGET_ROLE = Roles.SET_TARGET("supply");
    uint64 public immutable SUPPLY_TMP_TARGET_ROLE = Roles.TMP_TARGET("supply");
    uint64 public immutable BORROW_SET_TARGET_ROLE = Roles.SET_TARGET("borrow");
    uint64 public immutable BORROW_TMP_TARGET_ROLE = Roles.TMP_TARGET("borrow");
    uint64 public immutable VAULT_SET_TARGET_ROLE = Roles.SET_TARGET("vault");
    uint64 public immutable VAULT_TMP_TARGET_ROLE = Roles.TMP_TARGET("vault");
    uint64 public immutable FEED_SET_TARGET_ROLE = Roles.SET_TARGET("feed");
    uint64 public immutable FEED_TMP_TARGET_ROLE = Roles.TMP_TARGET("feed");
    uint64 public immutable POOL_SET_TARGET_ROLE = Roles.SET_TARGET("pool");
    uint64 public immutable POOL_TMP_TARGET_ROLE = Roles.TMP_TARGET("pool");

    uint64 public immutable POOL_CAP_SUPPLY_ROLE = Roles.CAP_SUPPLY("pool");
    uint64 public immutable POOL_TMP_SUPPLY_ROLE = Roles.TMP_SUPPLY("pool");
    uint64 public immutable POOL_CAP_BORROW_ROLE = Roles.CAP_BORROW("pool");
    uint64 public immutable POOL_TMP_BORROW_ROLE = Roles.TMP_BORROW("pool");

    uint64 public immutable FEED_ENLIST_ROLE = Roles.ENLIST("feed");
    uint64 public immutable FEED_RETWAP_ROLE = Roles.RETWAP("feed");
    uint64 public immutable POOL_ENLIST_ROLE = Roles.ENLIST("pool");
    uint64 public immutable POOL_ENWRAP_ROLE = Roles.ENWRAP("pool");
    uint64 public immutable POOL_SQUARE_ROLE = Roles.SQUARE("pool");
    uint64 public immutable ACMA_RELATE_ROLE = Roles.RELATE("acma");

    // ////////////////////////////////////////////////////////////////
    // Admin Roles
    // ////////////////////////////////////////////////////////////////

    uint64 public immutable SUPPLY_SET_TARGET_ADMIN_ROLE =
        Roles.SET_TARGET_ADMIN("supply");
    uint64 public immutable SUPPLY_TMP_TARGET_ADMIN_ROLE =
        Roles.TMP_TARGET_ADMIN("supply");
    uint64 public immutable BORROW_SET_TARGET_ADMIN_ROLE =
        Roles.SET_TARGET_ADMIN("borrow");
    uint64 public immutable BORROW_TMP_TARGET_ADMIN_ROLE =
        Roles.TMP_TARGET_ADMIN("borrow");
    uint64 public immutable VAULT_SET_TARGET_ADMIN_ROLE =
        Roles.SET_TARGET_ADMIN("vault");
    uint64 public immutable VAULT_TMP_TARGET_ADMIN_ROLE =
        Roles.TMP_TARGET_ADMIN("vault");
    uint64 public immutable FEED_SET_TARGET_ADMIN_ROLE =
        Roles.SET_TARGET_ADMIN("feed");
    uint64 public immutable FEED_TMP_TARGET_ADMIN_ROLE =
        Roles.TMP_TARGET_ADMIN("feed");
    uint64 public immutable POOL_SET_TARGET_ADMIN_ROLE =
        Roles.SET_TARGET_ADMIN("pool");
    uint64 public immutable POOL_TMP_TARGET_ADMIN_ROLE =
        Roles.TMP_TARGET_ADMIN("pool");

    uint64 public immutable POOL_CAP_SUPPLY_ADMIN_ROLE =
        Roles.CAP_SUPPLY_ADMIN("pool");
    uint64 public immutable POOL_TMP_SUPPLY_ADMIN_ROLE =
        Roles.TMP_SUPPLY_ADMIN("pool");
    uint64 public immutable POOL_CAP_BORROW_ADMIN_ROLE =
        Roles.CAP_BORROW_ADMIN("pool");
    uint64 public immutable POOL_TMP_BORROW_ADMIN_ROLE =
        Roles.TMP_BORROW_ADMIN("pool");

    uint64 public immutable FEED_ENLIST_ADMIN_ROLE = Roles.ENLIST_ADMIN("feed");
    uint64 public immutable FEED_RETWAP_ADMIN_ROLE = Roles.RETWAP_ADMIN("feed");
    uint64 public immutable POOL_ENLIST_ADMIN_ROLE = Roles.ENLIST_ADMIN("pool");
    uint64 public immutable POOL_ENWRAP_ADMIN_ROLE = Roles.ENWRAP_ADMIN("pool");
    uint64 public immutable POOL_SQUARE_ADMIN_ROLE = Roles.SQUARE_ADMIN("pool");
    uint64 public immutable ACMA_RELATE_ADMIN_ROLE = Roles.RELATE_ADMIN("acma");

    // ////////////////////////////////////////////////////////////////
    // Guard Roles
    // ////////////////////////////////////////////////////////////////

    uint64 public immutable SUPPLY_SET_TARGET_GUARD_ROLE =
        Roles.SET_TARGET_GUARD("supply");
    uint64 public immutable SUPPLY_TMP_TARGET_GUARD_ROLE =
        Roles.TMP_TARGET_GUARD("supply");
    uint64 public immutable BORROW_SET_TARGET_GUARD_ROLE =
        Roles.SET_TARGET_GUARD("borrow");
    uint64 public immutable BORROW_TMP_TARGET_GUARD_ROLE =
        Roles.TMP_TARGET_GUARD("borrow");
    uint64 public immutable VAULT_SET_TARGET_GUARD_ROLE =
        Roles.SET_TARGET_GUARD("vault");
    uint64 public immutable VAULT_TMP_TARGET_GUARD_ROLE =
        Roles.TMP_TARGET_GUARD("vault");
    uint64 public immutable FEED_SET_TARGET_GUARD_ROLE =
        Roles.SET_TARGET_GUARD("feed");
    uint64 public immutable FEED_TMP_TARGET_GUARD_ROLE =
        Roles.TMP_TARGET_GUARD("feed");
    uint64 public immutable POOL_SET_TARGET_GUARD_ROLE =
        Roles.SET_TARGET_GUARD("pool");
    uint64 public immutable POOL_TMP_TARGET_GUARD_ROLE =
        Roles.TMP_TARGET_GUARD("pool");

    uint64 public immutable POOL_CAP_SUPPLY_GUARD_ROLE =
        Roles.CAP_SUPPLY_GUARD("pool");
    uint64 public immutable POOL_TMP_SUPPLY_GUARD_ROLE =
        Roles.TMP_SUPPLY_GUARD("pool");
    uint64 public immutable POOL_CAP_BORROW_GUARD_ROLE =
        Roles.CAP_BORROW_GUARD("pool");
    uint64 public immutable POOL_TMP_BORROW_GUARD_ROLE =
        Roles.TMP_BORROW_GUARD("pool");

    uint64 public immutable FEED_ENLIST_GUARD_ROLE = Roles.ENLIST_GUARD("feed");
    uint64 public immutable FEED_RETWAP_GUARD_ROLE = Roles.RETWAP_GUARD("feed");
    uint64 public immutable POOL_ENLIST_GUARD_ROLE = Roles.ENLIST_GUARD("pool");
    uint64 public immutable POOL_ENWRAP_GUARD_ROLE = Roles.ENWRAP_GUARD("pool");
    uint64 public immutable POOL_SQUARE_GUARD_ROLE = Roles.SQUARE_GUARD("pool");
    uint64 public immutable ACMA_RELATE_GUARD_ROLE = Roles.RELATE_GUARD("acma");

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}
