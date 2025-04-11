// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IAcma} from "../../source/interface/Acma.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    function run() external {
        IAcma acma = IAcma(addressOf("ACMA"));
        //
        // Label Roles
        //
        vm.startBroadcast();
        acma.labelRole(acma.BORROW_SET_TARGET_ROLE(), "BORROW_SET_TARGET_ROLE");
        acma.labelRole(acma.SUPPLY_SET_TARGET_ROLE(), "SUPPLY_SET_TARGET_ROLE");
        acma.labelRole(acma.VAULT_SET_TARGET_ROLE(), "VAULT_SET_TARGET_ROLE");
        acma.labelRole(acma.FEED_SET_TARGET_ROLE(), "FEED_SET_TARGET_ROLE");
        acma.labelRole(acma.POOL_SET_TARGET_ROLE(), "POOL_SET_TARGET_ROLE");
        acma.labelRole(acma.BORROW_TMP_TARGET_ROLE(), "BORROW_TMP_TARGET_ROLE");
        acma.labelRole(acma.SUPPLY_TMP_TARGET_ROLE(), "SUPPLY_TMP_TARGET_ROLE");
        acma.labelRole(acma.VAULT_TMP_TARGET_ROLE(), "VAULT_TMP_TARGET_ROLE");
        acma.labelRole(acma.FEED_TMP_TARGET_ROLE(), "FEED_TMP_TARGET_ROLE");
        acma.labelRole(acma.POOL_TMP_TARGET_ROLE(), "POOL_TMP_TARGET_ROLE");
        acma.labelRole(acma.POOL_CAP_SUPPLY_ROLE(), "POOL_CAP_SUPPLY_ROLE");
        acma.labelRole(acma.POOL_CAP_BORROW_ROLE(), "POOL_CAP_BORROW_ROLE");
        acma.labelRole(acma.POOL_TMP_SUPPLY_ROLE(), "POOL_TMP_SUPPLY_ROLE");
        acma.labelRole(acma.POOL_TMP_BORROW_ROLE(), "POOL_TMP_BORROW_ROLE");
        acma.labelRole(acma.FEED_ENLIST_ROLE(), "FEED_ENLIST_ROLE");
        acma.labelRole(acma.FEED_RETWAP_ROLE(), "FEED_RETWAP_ROLE");
        acma.labelRole(acma.POOL_ENLIST_ROLE(), "POOL_ENLIST_ROLE");
        acma.labelRole(acma.POOL_ENWRAP_ROLE(), "POOL_ENWRAP_ROLE");
        acma.labelRole(acma.POOL_SQUARE_ROLE(), "POOL_SQUARE_ROLE");
        acma.labelRole(acma.ACMA_RELATE_ROLE(), "ACMA_RELATE_ROLE");
        vm.stopBroadcast();
        //
        // Label Admin Roles
        //
        vm.startBroadcast();
        acma.labelRole(
            acma.BORROW_SET_TARGET_ADMIN_ROLE(),
            "BORROW_SET_TARGET_ADMIN_ROLE"
        );
        acma.labelRole(
            acma.SUPPLY_SET_TARGET_ADMIN_ROLE(),
            "SUPPLY_SET_TARGET_ADMIN_ROLE"
        );
        acma.labelRole(
            acma.VAULT_SET_TARGET_ADMIN_ROLE(),
            "VAULT_SET_TARGET_ADMIN_ROLE"
        );
        acma.labelRole(
            acma.FEED_SET_TARGET_ADMIN_ROLE(),
            "FEED_SET_TARGET_ADMIN_ROLE"
        );
        acma.labelRole(
            acma.POOL_SET_TARGET_ADMIN_ROLE(),
            "POOL_SET_TARGET_ADMIN_ROLE"
        );
        acma.labelRole(
            acma.BORROW_TMP_TARGET_ADMIN_ROLE(),
            "BORROW_TMP_TARGET_ADMIN_ROLE"
        );
        acma.labelRole(
            acma.SUPPLY_TMP_TARGET_ADMIN_ROLE(),
            "SUPPLY_TMP_TARGET_ADMIN_ROLE"
        );
        acma.labelRole(
            acma.VAULT_TMP_TARGET_ADMIN_ROLE(),
            "VAULT_TMP_TARGET_ADMIN_ROLE"
        );
        acma.labelRole(
            acma.FEED_TMP_TARGET_ADMIN_ROLE(),
            "FEED_TMP_TARGET_ADMIN_ROLE"
        );
        acma.labelRole(
            acma.POOL_TMP_TARGET_ADMIN_ROLE(),
            "POOL_TMP_TARGET_ADMIN_ROLE"
        );
        acma.labelRole(
            acma.POOL_CAP_SUPPLY_ADMIN_ROLE(),
            "POOL_CAP_SUPPLY_ADMIN_ROLE"
        );
        acma.labelRole(
            acma.POOL_CAP_BORROW_ADMIN_ROLE(),
            "POOL_CAP_BORROW_ADMIN_ROLE"
        );
        acma.labelRole(
            acma.POOL_TMP_SUPPLY_ADMIN_ROLE(),
            "POOL_TMP_SUPPLY_ADMIN_ROLE"
        );
        acma.labelRole(
            acma.POOL_TMP_BORROW_ADMIN_ROLE(),
            "POOL_TMP_BORROW_ADMIN_ROLE"
        );
        acma.labelRole(acma.FEED_ENLIST_ADMIN_ROLE(), "FEED_ENLIST_ADMIN_ROLE");
        acma.labelRole(acma.FEED_RETWAP_ADMIN_ROLE(), "FEED_RETWAP_ADMIN_ROLE");
        acma.labelRole(acma.POOL_ENLIST_ADMIN_ROLE(), "POOL_ENLIST_ADMIN_ROLE");
        acma.labelRole(acma.POOL_ENWRAP_ADMIN_ROLE(), "POOL_ENWRAP_ADMIN_ROLE");
        acma.labelRole(acma.POOL_SQUARE_ADMIN_ROLE(), "POOL_SQUARE_ADMIN_ROLE");
        acma.labelRole(acma.ACMA_RELATE_ADMIN_ROLE(), "ACMA_RELATE_ADMIN_ROLE");
        vm.stopBroadcast();
        //
        // Label Guard Roles
        //
        vm.startBroadcast();
        acma.labelRole(
            acma.BORROW_SET_TARGET_GUARD_ROLE(),
            "BORROW_SET_TARGET_GUARD_ROLE"
        );
        acma.labelRole(
            acma.SUPPLY_SET_TARGET_GUARD_ROLE(),
            "SUPPLY_SET_TARGET_GUARD_ROLE"
        );
        acma.labelRole(
            acma.VAULT_SET_TARGET_GUARD_ROLE(),
            "VAULT_SET_TARGET_GUARD_ROLE"
        );
        acma.labelRole(
            acma.FEED_SET_TARGET_GUARD_ROLE(),
            "FEED_SET_TARGET_GUARD_ROLE"
        );
        acma.labelRole(
            acma.POOL_SET_TARGET_GUARD_ROLE(),
            "POOL_SET_TARGET_GUARD_ROLE"
        );
        acma.labelRole(
            acma.BORROW_TMP_TARGET_GUARD_ROLE(),
            "BORROW_TMP_TARGET_GUARD_ROLE"
        );
        acma.labelRole(
            acma.SUPPLY_TMP_TARGET_GUARD_ROLE(),
            "SUPPLY_TMP_TARGET_GUARD_ROLE"
        );
        acma.labelRole(
            acma.VAULT_TMP_TARGET_GUARD_ROLE(),
            "VAULT_TMP_TARGET_GUARD_ROLE"
        );
        acma.labelRole(
            acma.FEED_TMP_TARGET_GUARD_ROLE(),
            "FEED_TMP_TARGET_GUARD_ROLE"
        );
        acma.labelRole(
            acma.POOL_TMP_TARGET_GUARD_ROLE(),
            "POOL_TMP_TARGET_GUARD_ROLE"
        );
        acma.labelRole(
            acma.POOL_CAP_SUPPLY_GUARD_ROLE(),
            "POOL_CAP_SUPPLY_GUARD_ROLE"
        );
        acma.labelRole(
            acma.POOL_CAP_BORROW_GUARD_ROLE(),
            "POOL_CAP_BORROW_GUARD_ROLE"
        );
        acma.labelRole(
            acma.POOL_TMP_SUPPLY_GUARD_ROLE(),
            "POOL_TMP_SUPPLY_GUARD_ROLE"
        );
        acma.labelRole(
            acma.POOL_TMP_BORROW_GUARD_ROLE(),
            "POOL_TMP_BORROW_GUARD_ROLE"
        );
        acma.labelRole(acma.FEED_ENLIST_GUARD_ROLE(), "FEED_ENLIST_GUARD_ROLE");
        acma.labelRole(acma.FEED_RETWAP_GUARD_ROLE(), "FEED_RETWAP_GUARD_ROLE");
        acma.labelRole(acma.POOL_ENLIST_GUARD_ROLE(), "POOL_ENLIST_GUARD_ROLE");
        acma.labelRole(acma.POOL_ENWRAP_GUARD_ROLE(), "POOL_ENWRAP_GUARD_ROLE");
        acma.labelRole(acma.POOL_SQUARE_GUARD_ROLE(), "POOL_SQUARE_GUARD_ROLE");
        acma.labelRole(acma.ACMA_RELATE_GUARD_ROLE(), "ACMA_RELATE_GUARD_ROLE");
        vm.stopBroadcast();
        //
        // Set Admin Roles
        //
        vm.startBroadcast();
        acma.setRoleAdmin(
            acma.SUPPLY_SET_TARGET_ROLE(),
            acma.SUPPLY_SET_TARGET_ADMIN_ROLE()
        );
        acma.setRoleAdmin(
            acma.BORROW_SET_TARGET_ROLE(),
            acma.BORROW_SET_TARGET_ADMIN_ROLE()
        );
        acma.setRoleAdmin(
            acma.VAULT_SET_TARGET_ROLE(),
            acma.VAULT_SET_TARGET_ADMIN_ROLE()
        );
        acma.setRoleAdmin(
            acma.FEED_SET_TARGET_ROLE(),
            acma.FEED_SET_TARGET_ADMIN_ROLE()
        );
        acma.setRoleAdmin(
            acma.POOL_SET_TARGET_ROLE(),
            acma.POOL_SET_TARGET_ADMIN_ROLE()
        );
        acma.setRoleAdmin(
            acma.POOL_CAP_SUPPLY_ROLE(),
            acma.POOL_CAP_SUPPLY_ADMIN_ROLE()
        );
        acma.setRoleAdmin(
            acma.POOL_CAP_BORROW_ROLE(),
            acma.POOL_CAP_BORROW_ADMIN_ROLE()
        );
        acma.setRoleAdmin(
            acma.POOL_TMP_SUPPLY_ROLE(),
            acma.POOL_TMP_SUPPLY_ADMIN_ROLE()
        );
        acma.setRoleAdmin(
            acma.POOL_TMP_BORROW_ROLE(),
            acma.POOL_TMP_BORROW_ADMIN_ROLE()
        );
        acma.setRoleAdmin(
            acma.FEED_ENLIST_ROLE(),
            acma.FEED_ENLIST_ADMIN_ROLE()
        );
        acma.setRoleAdmin(
            acma.FEED_RETWAP_ROLE(),
            acma.FEED_RETWAP_ADMIN_ROLE()
        );
        acma.setRoleAdmin(
            acma.POOL_ENLIST_ROLE(),
            acma.POOL_ENLIST_ADMIN_ROLE()
        );
        acma.setRoleAdmin(
            acma.POOL_ENWRAP_ROLE(),
            acma.POOL_ENWRAP_ADMIN_ROLE()
        );
        acma.setRoleAdmin(
            acma.POOL_SQUARE_ROLE(),
            acma.POOL_SQUARE_ADMIN_ROLE()
        );
        acma.setRoleAdmin(
            acma.ACMA_RELATE_ROLE(),
            acma.ACMA_RELATE_ADMIN_ROLE()
        );
        vm.stopBroadcast();
        //
        // Set Guard Roles
        //
        vm.startBroadcast();
        acma.setRoleGuardian(
            acma.SUPPLY_SET_TARGET_ROLE(),
            acma.SUPPLY_SET_TARGET_GUARD_ROLE()
        );
        acma.setRoleGuardian(
            acma.BORROW_SET_TARGET_ROLE(),
            acma.BORROW_SET_TARGET_GUARD_ROLE()
        );
        acma.setRoleGuardian(
            acma.VAULT_SET_TARGET_ROLE(),
            acma.VAULT_SET_TARGET_GUARD_ROLE()
        );
        acma.setRoleGuardian(
            acma.FEED_SET_TARGET_ROLE(),
            acma.FEED_SET_TARGET_GUARD_ROLE()
        );
        acma.setRoleGuardian(
            acma.POOL_SET_TARGET_ROLE(),
            acma.POOL_SET_TARGET_GUARD_ROLE()
        );
        acma.setRoleGuardian(
            acma.POOL_CAP_SUPPLY_ROLE(),
            acma.POOL_CAP_SUPPLY_GUARD_ROLE()
        );
        acma.setRoleGuardian(
            acma.POOL_CAP_BORROW_ROLE(),
            acma.POOL_CAP_BORROW_GUARD_ROLE()
        );
        acma.setRoleGuardian(
            acma.POOL_TMP_SUPPLY_ROLE(),
            acma.POOL_TMP_SUPPLY_GUARD_ROLE()
        );
        acma.setRoleGuardian(
            acma.POOL_TMP_BORROW_ROLE(),
            acma.POOL_TMP_BORROW_GUARD_ROLE()
        );
        acma.setRoleGuardian(
            acma.FEED_ENLIST_ROLE(),
            acma.FEED_ENLIST_GUARD_ROLE()
        );
        acma.setRoleGuardian(
            acma.FEED_RETWAP_ROLE(),
            acma.FEED_RETWAP_GUARD_ROLE()
        );
        acma.setRoleGuardian(
            acma.POOL_ENLIST_ROLE(),
            acma.POOL_ENLIST_GUARD_ROLE()
        );
        acma.setRoleGuardian(
            acma.POOL_ENWRAP_ROLE(),
            acma.POOL_ENWRAP_GUARD_ROLE()
        );
        acma.setRoleGuardian(
            acma.POOL_SQUARE_ROLE(),
            acma.POOL_SQUARE_GUARD_ROLE()
        );
        acma.setRoleGuardian(
            acma.ACMA_RELATE_ROLE(),
            acma.ACMA_RELATE_GUARD_ROLE()
        );
        vm.stopBroadcast();
    }
}
