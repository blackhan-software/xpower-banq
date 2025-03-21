// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

/**
 * @title Weight of borrow and supply positions
 */
struct Weight {
    /** borrow multiplier, e.g. 255 => 100.0% */
    uint8 borrow;
    /** supply multiplier, e.g. 170 => 66.67% */
    uint8 supply;
}
