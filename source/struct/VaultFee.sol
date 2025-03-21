// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

/**
 * @title Entry and exits fees of vault
 */
struct VaultFee {
    /** entry fee of vault (basis points: 1e14) */
    uint256 entry;
    /** entry fee recipient */
    address entryRecipient;
    /** exit fee of vault (basis points: 1e14) */
    uint256 exit;
    /** exit fee recipient */
    address exitRecipient;
}
