// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

/**
 * @title Health of borrow and supply positions
 */
struct Health {
    /** [w]eighted [n]et [a]sset [v]alue of borrow position */
    uint256 wnav_borrow;
    /** [w]eighted [n]et [a]sset [v]alue of supply position */
    uint256 wnav_supply;
}
