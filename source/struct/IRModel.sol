// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

/**
 * @title Utilization -vs- rate and spread
 */
struct IRModel {
    /** optimal rate, e.g. 10e16 for 10% */
    uint256 rate;
    /** interest spread e.g. 1e16 for ±1% */
    uint256 spread;
    /** optimal utilization, e.g. 90e16 for 90% */
    uint256 util;
}
