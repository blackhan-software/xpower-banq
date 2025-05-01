// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

/**
 * @title Rate limitation range
 */
struct RateLimit {
    /** maximum rate-limit */
    uint256 max;
    /** minimum rate-limit */
    uint256 min;
}
