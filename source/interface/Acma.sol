// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IAccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";

interface IAcma is IAccessManager {
    /**
     * Relates for the target contract a selector and a role-id.
     *
     * @param target contract to relate for
     * @param selector to relate
     * @param role_id to relate
     */
    function relate(address target, bytes4 selector, uint64 role_id) external;

    /** Role allows to set-target parameters on supply-positions. */
    function SUPPLY_SET_TARGET_ROLE() external view returns (uint64);

    /** Role allows to admin SUPPLY_SET_TARGET_ROLE. */
    function SUPPLY_SET_TARGET_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard SUPPLY_SET_TARGET_ROLE. */
    function SUPPLY_SET_TARGET_GUARD_ROLE() external view returns (uint64);

    /** Role allows to set-target parameters on supply-positions (with duration). */
    function SUPPLY_TMP_TARGET_ROLE() external view returns (uint64);

    /** Role allows to admin SUPPLY_TMP_TARGET_ROLE. */
    function SUPPLY_TMP_TARGET_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard SUPPLY_TMP_TARGET_ROLE. */
    function SUPPLY_TMP_TARGET_GUARD_ROLE() external view returns (uint64);

    /** Role allows to set-target parameters on borrow-positions. */
    function BORROW_SET_TARGET_ROLE() external view returns (uint64);

    /** Role allows to admin BORROW_SET_TARGET_ROLE. */
    function BORROW_SET_TARGET_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard BORROW_SET_TARGET_ROLE. */
    function BORROW_SET_TARGET_GUARD_ROLE() external view returns (uint64);

    /** Role allows to set-target parameters on borrow-positions (with duration). */
    function BORROW_TMP_TARGET_ROLE() external view returns (uint64);

    /** Role allows to admin BORROW_TMP_TARGET_ROLE. */
    function BORROW_TMP_TARGET_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard BORROW_TMP_TARGET_ROLE. */
    function BORROW_TMP_TARGET_GUARD_ROLE() external view returns (uint64);

    /** Role allows to set-target parameters on vaults. */
    function VAULT_SET_TARGET_ROLE() external view returns (uint64);

    /** Role allows to admin VAULT_SET_TARGET_ROLE. */
    function VAULT_SET_TARGET_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard VAULT_SET_TARGET_ROLE. */
    function VAULT_SET_TARGET_GUARD_ROLE() external view returns (uint64);

    /** Role allows to set-target parameters on vaults (with duration). */
    function VAULT_TMP_TARGET_ROLE() external view returns (uint64);

    /** Role allows to admin VAULT_TMP_TARGET_ROLE. */
    function VAULT_TMP_TARGET_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard VAULT_TMP_TARGET_ROLE. */
    function VAULT_TMP_TARGET_GUARD_ROLE() external view returns (uint64);

    /** Role allows to set-target parameters on oracle-feeds. */
    function FEED_SET_TARGET_ROLE() external view returns (uint64);

    /** Role allows to admin FEED_SET_TARGET_ROLE. */
    function FEED_SET_TARGET_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard FEED_SET_TARGET_ROLE. */
    function FEED_SET_TARGET_GUARD_ROLE() external view returns (uint64);

    /** Role allows to set-target parameters on oracle-feeds (with duration). */
    function FEED_TMP_TARGET_ROLE() external view returns (uint64);

    /** Role allows to admin FEED_TMP_TARGET_ROLE. */
    function FEED_TMP_TARGET_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard FEED_TMP_TARGET_ROLE. */
    function FEED_TMP_TARGET_GUARD_ROLE() external view returns (uint64);

    /** Role allows to set-target parameters on pools. */
    function POOL_SET_TARGET_ROLE() external view returns (uint64);

    /** Role allows to admin POOL_SET_TARGET_ROLE. */
    function POOL_SET_TARGET_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard POOL_SET_TARGET_ROLE. */
    function POOL_SET_TARGET_GUARD_ROLE() external view returns (uint64);

    /** Role allows to set-target parameters on pools (with duration). */
    function POOL_TMP_TARGET_ROLE() external view returns (uint64);

    /** Role allows to admin POOL_TMP_TARGET_ROLE. */
    function POOL_TMP_TARGET_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard POOL_TMP_TARGET_ROLE. */
    function POOL_TMP_TARGET_GUARD_ROLE() external view returns (uint64);

    /** Role allows to cap supply-positions on pools. */
    function POOL_CAP_SUPPLY_ROLE() external view returns (uint64);

    /** Role allows to admin POOL_CAP_SUPPLY_ROLE. */
    function POOL_CAP_SUPPLY_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard POOL_CAP_SUPPLY_ROLE. */
    function POOL_CAP_SUPPLY_GUARD_ROLE() external view returns (uint64);

    /** Role allows to cap supply-positions on pools (with duration). */
    function POOL_TMP_SUPPLY_ROLE() external view returns (uint64);

    /** Role allows to admin POOL_TMP_SUPPLY_ROLE. */
    function POOL_TMP_SUPPLY_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard POOL_TMP_SUPPLY_ROLE. */
    function POOL_TMP_SUPPLY_GUARD_ROLE() external view returns (uint64);

    /** Role allows to cap borrow-positions on pools. */
    function POOL_CAP_BORROW_ROLE() external view returns (uint64);

    /** Role allows to admin POOL_CAP_BORROW_ROLE. */
    function POOL_CAP_BORROW_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard POOL_CAP_BORROW_ROLE. */
    function POOL_CAP_BORROW_GUARD_ROLE() external view returns (uint64);

    /** Role allows to cap borrow-positions on pools (with duration). */
    function POOL_TMP_BORROW_ROLE() external view returns (uint64);

    /** Role allows to admin POOL_TMP_BORROW_ROLE. */
    function POOL_TMP_BORROW_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard POOL_TMP_BORROW_ROLE. */
    function POOL_TMP_BORROW_GUARD_ROLE() external view returns (uint64);

    /** Role allows to enlist oracle-feeds. */
    function FEED_ENLIST_ROLE() external view returns (uint64);

    /** Role allows to admin FEED_ENLIST_ROLE. */
    function FEED_ENLIST_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard FEED_ENLIST_ROLE. */
    function FEED_ENLIST_GUARD_ROLE() external view returns (uint64);

    /** Role allows to retwap oracle-feeds. */
    function FEED_RETWAP_ROLE() external view returns (uint64);

    /** Role allows to admin FEED_RETWAP_ROLE. */
    function FEED_RETWAP_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard FEED_RETWAP_ROLE. */
    function FEED_RETWAP_GUARD_ROLE() external view returns (uint64);

    /** Role allows to enlist pool-tokens (if pre-registered). */
    function POOL_ENLIST_ROLE() external view returns (uint64);

    /** Role allows to admin POOL_ENLIST_ROLE. */
    function POOL_ENLIST_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard POOL_ENLIST_ROLE. */
    function POOL_ENLIST_GUARD_ROLE() external view returns (uint64);

    /** Role allows to enwrap pool-tokens (if enlisted). */
    function POOL_ENWRAP_ROLE() external view returns (uint64);

    /** Role allows to admin POOL_ENWRAP_ROLE. */
    function POOL_ENWRAP_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard POOL_ENWRAP_ROLE. */
    function POOL_ENWRAP_GUARD_ROLE() external view returns (uint64);

    /** Role allows to square pool-victims (i.e. liquidate). */
    function POOL_SQUARE_ROLE() external view returns (uint64);

    /** Role allows to admin POOL_SQUARE_ROLE. */
    function POOL_SQUARE_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard POOL_SQUARE_ROLE. */
    function POOL_SQUARE_GUARD_ROLE() external view returns (uint64);

    /** Role allows to relate contract selectors with roles. */
    function ACMA_RELATE_ROLE() external view returns (uint64);

    /** Role allows to admin ACMA_RELATE_ROLE. */
    function ACMA_RELATE_ADMIN_ROLE() external view returns (uint64);

    /** Role allows to guard ACMA_RELATE_ROLE. */
    function ACMA_RELATE_GUARD_ROLE() external view returns (uint64);
}
