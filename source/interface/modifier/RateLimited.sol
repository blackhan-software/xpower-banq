// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

interface IRateLimited {
    /**
     * Thrown on premature function invocation.
     *
     * @param key hash of selector and arguments
     * @param dt duration of the cap-limit pending (seconds)
     */
    error RateLimited(bytes32 key, uint256 dt);
}
